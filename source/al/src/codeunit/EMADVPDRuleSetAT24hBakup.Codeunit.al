codeunit 62084 "EMADV PD Rule Set AT 24hBakup" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        SetupPerDiemCalculationTable(PerDiem, PerDiemDetail);
        /*
        if EMSetup."Enable Per Diem Destinations" then
            Message('TODO')
        else
            
        //CalculateSingleDestination(PerDiem, PerDiemDetail);
        */
    end;



    local procedure CalculateSingleDestination(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        FirstDay: Boolean;
        LastDay: Boolean;
        DayDuration: Duration;
    begin
        //FirstDay := IsFirstDay(PerDiem, PerDiemDetail);
        LastDay := PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time");

        case true of
            // 1st day AND last day = One day trip
            (FirstDay and LastDay):
                begin
                    DayDuration := PerDiem."Return Date/Time" - PerDiem."Departure Date/Time";
                end;
            // 1st day and NOT last day
            (FirstDay and (not LastDay)):
                begin
                    DayDuration := CreateDateTime(PerDiemDetail.Date + 1, 000000T) - PerDiem."Departure Date/Time";
                end;

            // Last day
            ((not FirstDay) and LastDay):
                begin
                    DayDuration := PerDiem."Return Date/Time" - CreateDateTime(PerDiemDetail.Date, 000000T);
                end;
            //in-between day    
            else begin
                DayDuration := CreateDateTime(PerDiemDetail.Date + 1, 000000T) - CreateDateTime(PerDiemDetail.Date, 000000T);
            end;

        end;
    end;

    local procedure SetupPerDiemCalculationTable(var PerDiem: Record "CEM Per Diem"; var CurrPerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemDetailDest: record "CEM Per Diem Detail Dest.";
        Day: Integer;
        DepartureTime: Time;
        CurrEntryNo: Integer;
        CurrCountry: Code[10];
        CurrTime: Time;


    //CurrDate: date;
    begin

        // This procedure is only used on the first per diem detail entry
        if CurrPerDiemDetail."Entry No." > 1 then
            exit;

        if not EMSetup.Get() then
            exit;

        ResetPerDiemCalculation(PerDiem);

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.IsEmpty then
            exit;

        CurrCountry := PerDiem."Departure Country/Region";
        CurrTime := DT2Time(PerDiem."Departure Date/Time");
        NewDayTime := CurrTime;  // for per Day it's 000000T
        LastNewDayDate := 0D;

        //TODO Setloadfields PerDiemDetail.SetLoadFields(D)

        CreateWholeDayPerDiemCalculationEntries(PerDiem);

        // PerDiemDetail.FindSet();
        // repeat

        //     //CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, DepartureTime, 000000T);

        //     if EMSetup."Enable Per Diem Destinations" then
        //         AddDetailDestinations(PerDiem, PerDiemDetail, Currtime, CurrCountry);



        //     case true of
        //         IsFirstDay(PerDiem, PerDiemDetail.Date):
        //             begin
        //                 if IsLastDay(PerDiem, PerDiemDetail.Date) then begin
        //                     CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrTime, DT2Time(PerDiem."Return Date/Time"), PerDiem."Destination Country/Region");
        //                     CurrTime := DT2Time(PerDiem."Return Date/Time");
        //                 end else begin
        //                     CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrTime, 000000T, CurrCountry);
        //                     CurrTime := 000000T;
        //                 end;
        //             end;
        //         IsLastDay(PerDiem, PerDiemDetail.Date):
        //             begin
        //                 if not (IsFirstDay(PerDiem, PerDiemDetail.Date)) then
        //                     if (DT2Time(PerDiem."Return Date/Time") > DT2Time(PerDiem."Departure Date/Time")) then begin
        //                         if CurrTime <> 000000T then
        //                             CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, 000000T, CurrTime, CurrCountry);
        //                         CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrTime, DT2Time(PerDiem."Return Date/Time"), CurrCountry);
        //                     end else
        //                         CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, 000000T, DT2Time(PerDiem."Return Date/Time"), CurrCountry);
        //             end;
        //         else
        //             if (not IsFirstDay(PerDiem, PerDiemDetail.Date)) and (not IsLastDay(PerDiem, PerDiemDetail.Date)) then begin
        //                 if CurrTime <> 000000T then
        //                     CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, 000000T, CurrTime, CurrCountry);
        //                 CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrTime, 000000T, CurrCountry);
        //                 CurrTime := 000000T;
        //             end;
        //     end;
        // until PerDiemDetail.Next() = 0;

        //for Dayi := 1 to PerDiemDetail2 do begin
        //for Day := 0 to DT2Date(PerDiem."Return Date/Time") - DT2Date(PerDiem."Departure Date/Time") do begin

    end;


    //end;

    local procedure AddDetailDestinations(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"; var CurrArrivalTime: Time; var CurrCountryCode: Code[10]): Boolean
    var
        PerDiemDetDest: Record "CEM Per Diem Detail Dest.";
    begin
        PerDiemDetDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemDetDest.SetRange("Per Diem Detail Entry No.", PerDiemDetail."Entry No.");
        if PerDiemDetDest.IsEmpty then
            exit;

        PerDiemDetDest.FindSet();

        repeat
            CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrArrivalTime, PerDiemDetDest."Arrival Time", CurrCountryCode);
            CurrArrivalTime := PerDiemDetDest."Arrival Time";
            CurrCountryCode := PerDiemDetDest."Destination Country/Region";
        until PerDiemDetDest.Next() = 0;
        //CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, CurrArrivalTime, PerDiemDetDest."Arrival Time", CurrCountryCode);
        exit(true);
    end;

    local procedure CreateWholeDayPerDiemCalculationEntries(var PerDiem: Record "CEM Per Diem")
    var
        //PerDiemDetDestBuffer: Record "CEM Per Diem Detail Dest." temporary;
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemCalcBuffer: Record "EMADV Per Diem Calculation";
        PerDiemDetDest: Record "CEM Per Diem Detail Dest.";
        //PerDiemDetDestBuffer: Record "CEM Per Diem Detail Dest." temporary;
        FromDateTime: DateTime;
        ReturnDateTime: DateTime;
        DayBreakTime: Time;
        Day: Integer;

        FirstDayDate: Date;
        FirstDayTime: Time;
        LastDayDate: Date;
        LastDayTime: Time;
        NewDayTime: Time;

        CurrEntryNo: Integer;
        CurrCountry: Code[10];
        CurrTime: time;
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.IsEmpty then
            exit;
        PerDiemDetail.FindSet();

        CurrCountry := PerDiem."Departure Country/Region";
        CurrTime := DT2Time(PerDiem."Departure Date/Time");
        CurrEntryNo += 1;


        PerDiemCalcBuffer.Validate("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemCalcBuffer."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
        PerDiemCalcBuffer."Entry No." := CurrEntryNo;
        PerDiemCalcBuffer.Validate("From DateTime", CreateDateTime(PerDiemDetail.Date, CurrTime));
        PerDiemCalcBuffer.Validate("Country/Region", CurrCountry);
        PerDiemCalcBuffer.Insert();
        repeat
            CurrEntryNo += 1;
            Clear(PerDiemCalcBuffer);


            PerDiemDetDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
            PerDiemDetDest.SetRange("Per Diem Detail Entry No.", PerDiemDetail."Entry No.");
            if PerDiemDetDest.IsEmpty then begin
                PerDiemCalcBuffer.Validate("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemCalcBuffer."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
                PerDiemCalcBuffer."Entry No." := CurrEntryNo;
                if (CreateDateTime(PerDiemDetail.Date, CurrTime)) < PerDiem."Return Date/Time" then
                    PerDiemCalcBuffer.Validate("From DateTime", CreateDateTime(PerDiemDetail.Date, CurrTime))
                else
                    PerDiemCalcBuffer.Validate("From DateTime", PerDiem."Return Date/Time");
                PerDiemCalcBuffer.Validate("Country/Region", CurrCountry);
                PerDiemCalcBuffer.Insert();
            end else begin
                PerDiemDetDest.FindSet();
                repeat
                    CurrEntryNo += 1;
                    PerDiemCalcBuffer.init;
                    PerDiemCalcBuffer.Validate("Per Diem Entry No.", PerDiem."Entry No.");
                    PerDiemCalcBuffer.Validate("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                    PerDiemCalcBuffer."Entry No." := CurrEntryNo;
                    PerDiemCalcBuffer.Validate("From DateTime", CreateDateTime(PerDiemDetail.Date, PerDiemDetDest."Arrival Time"));
                    PerDiemCalcBuffer.Validate("Country/Region", PerDiemDetDest."Destination Country/Region");
                    PerDiemCalcBuffer.Insert();
                    CurrTime := PerDiemDetDest."Arrival Time";
                    CurrCountry := PerDiemDetDest."Destination Country/Region";
                until PerDiemDetDest.next = 0;
            end;
        until PerDiemDetail.Next() = 0;

        IF PerDiemCalcBuffer.FindLast() then begin
            CurrTime := DT2Time(PerDiem."Return Date/Time");
            //CurrCountry := PerDiem.
            repeat
                PerDiemCalcBuffer.Validate("To DateTime", CreateDateTime(DT2Date(PerDiemCalcBuffer."From DateTime"), CurrTime));
                PerDiemCalcBuffer.Modify();
                CurrTime := DT2Time(PerDiemCalcBuffer."From DateTime");
            until PerDiemCalcBuffer.Next(-1) = 0;
        end;
        //Now put in calculation
        Message('Temp records: %1', PerDiemCalcBuffer.Count);
        /*PerDiemDetail.Reset();
        if PerDiemCalcBuffer.FindFirst() then
            repeat
                if PerDiemDetail.Get(PerDiemCalcBuffer."Per Diem Entry No.", PerDiemCalcBuffer."Per Diem Detail Entry No.") then begin
                    PerDiemCalculation.init;
                    PerDiemCalculation.Validate("Per Diem Entry No.", PerDiemCalcBuffer."Per Diem Entry No.");
                    PerDiemCalculation.Validate("From DateTime", CreateDateTime(PerDiemDetail.Date, PerDiemDetDest."Arrival Time"));
                    PerDiemCalculation."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
                    PerDiemCalculation.Insert(true);
                end;

            until PerDiemCalcBuffer.Next() = 0;

*/
        //Day += 1;
        //PerDiemCalculation.Validate("Per Diem Entry No.", PerDiem."Entry No.");
        //if DT2Date(PerDiem."Return Date/Time") = PerDiemDetail.Date then
        //    if DT2Time(PerDiem."Return Date/Time") <= DT2Time(PerDiem."Departure Date/Time") then
        //        PerDiemCalculation.Validate("From DateTime", PerDiem."Return Date/Time")


        //     if DT2Date(PerDiem."Return Date/Time") = PerDiemDetail.Date then begin
        //         PerDiemCalculation.Validate("From DateTime", CreateDateTime(PerDiemDetail.Date, DT2Time(PerDiem."Departure Date/Time")));
        //         //if DT2Date(PerDiem."Return Date/Time") = PerDiemDetail.Date then begin
        //         //    if DT2Time(PerDiem."Return Date/Time") <= DT2Time(PerDiem."Departure Date/Time") then
        //         //        PerDiemCalculation.Validate("To DateTime", PerDiem."Return Date/Time")
        //         //    else
        //         //end;
        //         //CreateDateTime(PerDiemDetail.Date, DT2Time(PerDiem."Departure Date/Time")) then
        //         //    PerDiemCalculation.Validate("To DateTime", PerDiem."Return Date/Time")
        //         //else
        //         //PerDiemCalculation.Validate("To DateTime", CreateDateTime(PerDiemDetail.Date + 1, DT2Time(PerDiem."Departure Date/Time")));

        //         PerDiemCalculation.Day := Day;
        //         PerDiemCalculation."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
        //         //if DT2Date(PerDiem."Return Date/Time") = PerDiemDetail.Date then 
        //         //    if DT2Time(PerDiem."Return Date/Time") <= PerDiem.DT2Time(PerDiem."Departure Date/Time") then
        //         //PerDiemCalculation."From DateTime" := CreateDateTime(PerDiemDetail.Date,)
        //         PerDiemCalculation.Insert(true);
        // until PerDiemDetail.Next() = 0;
        /*Day := 1;
        //DayBreakTime := DT2Time(PerDiem."Departure Date/Time");
        //FromDateTime := PerDiem."Departure Date/Time";
        FirstDayDate := DT2Date(PerDiem."Departure Date/Time");
        FirstDayTime := DT2Time(PerDiem."Departure Date/Time");
        LastDayDate := DT2Date(PerDiem."Return Date/Time");
        LastDayTime := DT2Time(PerDiem."Return Date/Time");
        NewDayTime := FirstDayTime;

        GetPerDiemDetDestinationBuffer(PerDiem, PerDiemDetDestBuffer);

        // Create first calculation entry
        Clear(PerDiemCalculation);
        PerDiemCalculation."Per Diem Entry No." := PerDiem."Entry No.";
        PerDiemCalculation."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
        PerDiemCalculation.Day := Day;
        PerDiemCalculation."From DateTime" := CreateDateTime(FirstDayDate, FirstDayTime);
        if (LastDayDate = FirstDayDate) and (LastDayTime <= NewDayTime) then
            PerDiemCalculation."To DateTime" := CreateDateTime(LastDayDate, LastDayTime)
        else
            PerDiemCalculation."Country/Region" := PerDiem."Departure Country/Region";
        PerDiemCalculation.Insert(true);


        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemDetail.FindSet();


        DayBreakTime := DT2Time(PerDiem."Departure Date/Time");
        ReturnDateTime := PerDiem."Return Date/Time";

        repeat
            Clear(PerDiemCalculation);
            PerDiemCalculation."Per Diem Entry No." := PerDiem."Entry No.";
            PerDiemCalculation.Day := PerDiemDetail."Entry No.";
            if PerDiemDetail."Entry No." = 1 then begin
                PerDiemCalculation."From DateTime" := PerDiem."Departure Date/Time";
                PerDiemCalculation."Country/Region" := PerDiem."Departure Country/Region";
            end else
                PerDiemCalculation."From DateTime" := CreateDateTime(PerDiemDetail.Date, DT2Time(PerDiem."Departure Date/Time"));

            if PerDiem."Return Date/Time" <= CreateDateTime(PerDiemDetail.Date + 1, DT2Time(PerDiem."Departure Date/Time")) then begin
                PerDiemCalculation."To DateTime" := PerDiem."Return Date/Time";
                PerDiemCalculation."Country/Region" := PerDiem."Destination Country/Region";
            end else
                PerDiemCalculation."To DateTime" := CreateDateTime(PerDiemDetail.Date + 1, DT2Time(PerDiem."Departure Date/Time"));

            PerDiemCalculation.Insert(true)
        until PerDiemDetail.Next() = 0;
        */
    end;

    local procedure GetPerDiemDetDestinationBuffer(var
                                                       PerDiem: Record "CEM Per Diem";

var
PerDiemDetDestBuffer: Record "CEM Per Diem Detail Dest." temporary)
    var
        PerDiemDetDest: Record "CEM Per Diem Detail Dest.";
    begin
        PerDiemDetDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        //PerDiemDetDest.SetRange("Per Diem Detail Entry No.", PerDiemDetail."Entry No.");
        //PerDiemDetDest.SetRange("Arrival Time", FromTime, ToTime);
        if PerDiemDetDest.IsEmpty then
            exit;

        PerDiemDetDest.FindSet();

        repeat
            PerDiemDetDestBuffer.TransferFields(PerDiemDetDest);
            PerDiemDetDestBuffer.Insert();
        until PerDiemDetDest.Next() = 0;
    end;

    local procedure CreatePerDiemCalculationEntry2(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; FromDateTime: DateTime; ToDateTime: DateTime; DestCountry: Code[10])
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation."Per Diem Entry No." := PerDiem."Entry No.";

        PerDiemCalculation."From DateTime" := FromDateTime;
        PerDiemCalculation."To DateTime" := ToDateTime;
        PerDiemCalculation."Country/Region" := DestCountry;
        if not PerDiemCalculation.Insert(true) then
            message('Fehler bei %1 - %2', PerDiem."Entry No.", PerDiemDetail."Entry No.");
    end;

    local procedure CreatePerDiemCalculationEntry(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; FromTime: Time; ToTime: Time; DestCountry: Code[10])
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        /*if (LastNewDayDate = 0D) or (LastNewDayDate < PerDiemDetail.Date) or ((PerDiemDetail.Date = LastNewDayDate) and (NewDayTime < FromTime)) then begin
            LastNewDayDate := PerDiemDetail.Date;
            CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, FromTime, ToTime, DestCountry);
        end;
*/
        PerDiemCalculation."Per Diem Entry No." := PerDiem."Entry No.";
        //PerDiemCalculation.Date := PerDiemDetail.Date;
        //PerDiemCalculation."From Time" := FromTime;
        //PerDiemCalculation."To Time" := ToTime;
        PerDiemCalculation."Country/Region" := DestCountry;
        //if ToTime = 000000T then
        //PerDiemCalculation."Day Duration" := CreateDateTime(PerDiemCalculation.Date + 1, PerDiemCalculation."To Time") - CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."From Time")
        //else
        // PerDiemCalculation."Day Duration" := CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."To Time") - CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."From Time");
        //PerDiemCalculation."Day Duration" := PerDiemCalculation."Duration Integer" / (1000 * 60 * 60), 1, '>'); //1000msec * 60sec * 60min = hours
        if not PerDiemCalculation.Insert(true) then
            message('Fehler bei %1 - %2', PerDiem."Entry No.", PerDiemDetail."Entry No.");
    end;

    local procedure ResetPerDiemCalculation(var PerDiem: Record "CEM Per Diem")
    PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if not PerDiemCalculation.IsEmpty then
            PerDiemCalculation.DeleteAll(true);
    end;

    local procedure IsFirstDay(var PerDiem: Record "CEM Per Diem"; CurrentDate: Date): Boolean
    begin
        exit(CurrentDate = DT2Date(PerDiem."Departure Date/Time"));
    end;

    local procedure IsLastDay(var PerDiem: Record "CEM Per Diem"; CurrentDate: Date): Boolean
    begin
        exit(CurrentDate = DT2Date(PerDiem."Return Date/Time"));
    end;

    local procedure GetPerDiemDetDestinationBuffer(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemDetDestBuffer: Record "CEM Per Diem Detail Dest." temporary; FromTime: Time; arg: Variant; DestinationCountryRegion: Code[10])
    begin
        Error('Procedure GetPerDiemDetDestinationBuffer not implemented.');
    end;



    var
        NewDayTime: Time;
        LastNewDayDate: Date;

}

/*if IsDepartureTime then
       if IsLastDay(PerDiem, PerDiemDetail) then
           //if DT2Time(PerDiem."Return Date/Time") > DT2Time(PerDiem."Departure Date/Time") then 
           //CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), DT2Time(PerDiem."Return Date/Time"), '')
           CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), DT2Time(PerDiem."Return Date/Time"), '')
       else
           CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), 000000T, '')
   else
       if IsLastDay(PerDiem, PerDiemDetail) then
           CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, 000000T, DT2Time(PerDiem."Return Date/Time"), '')
       else begin
           CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, 000000T, DT2Time(PerDiem."Departure Date/Time"), '');
           CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), 000000T, '');
       end;


end;
*/
