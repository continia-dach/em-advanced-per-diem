codeunit 62084 "EMADV PD Rule Set AT 24h" implements "EMADV IPerDiemRuleSetProvider"
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
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemDetailDest: record "CEM Per Diem Detail Dest.";
        Day: Integer;
        IsDepartureTime: Boolean;
        CurrEntryNo: Integer;
    //CurrDate: date;
    begin
        // This procedure is only used on the first per diem detail entry
        if CurrPerDiemDetail."Entry No." > 1 then
            exit;
        ResetPerDiemCalculation(PerDiem);

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.IsEmpty then
            exit;

        //TODO Setloadfields PerDiemDetail.SetLoadFields(D)
        PerDiemDetail.FindSet();
        repeat
            IsDepartureTime := not IsDepartureTime;
            CurrDate := PerDiemDetail.Date + Day;
            if IsFirstDay(PerDiem, PerDiemDetail.Date) then begin
                if IsLastDay(PerDiem, PerDiemDetail.Date) then
                    CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), DT2Time(PerDiem."Return Date/Time"), '')
                else
                    CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), 000000T, '');
            end;

            if IsLastDay(PerDiem, PerDiemDetail.Date) then begin
                if not (IsFirstDay(PerDiem, PerDiemDetail.Date)) then
                    if (DT2Time(PerDiem."Return Date/Time") > DT2Time(PerDiem."Departure Date/Time")) then begin
                        CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, 000000T, DT2Time(PerDiem."Departure Date/Time"), '');
                        CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), DT2Time(PerDiem."Return Date/Time"), '');
                    end else
                        CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, 000000T, DT2Time(PerDiem."Return Date/Time"), '');
            end;

            if (not IsFirstDay(PerDiem, PerDiemDetail.Date)) and (not IsLastDay(PerDiem, PerDiemDetail.Date)) then begin
                CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, 000000T, DT2Time(PerDiem."Departure Date/Time"), '');
                CreatePerDiemCalculationEntry(PerDiem, PerDiemDetail, PerDiemDetail.Date + Day, DT2Time(PerDiem."Departure Date/Time"), 000000T, '');
            end;
        until PerDiemDetail.Next() = 0;


        //for Dayi := 1 to PerDiemDetail2 do begin
        //for Day := 0 to DT2Date(PerDiem."Return Date/Time") - DT2Date(PerDiem."Departure Date/Time") do begin

    end;

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
    end;

    local procedure CreatePerDiemCalculationEntry(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; EntryDate: Date; FromTime: Time; ToTime: Time; DestCountry: Code[10])
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation."Per Diem Entry No." := PerDiem."Entry No.";
        PerDiemCalculation.Date := EntryDate;
        PerDiemCalculation."From Time" := FromTime;
        PerDiemCalculation."To Time" := ToTime;
        PerDiemCalculation."Destination Country/Region" := DestCountry;
        if ToTime = 000000T then
            PerDiemCalculation."Day Duration" := CreateDateTime(PerDiemCalculation.Date + 1, PerDiemCalculation."To Time") - CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."From Time")
        else
            PerDiemCalculation."Day Duration" := CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."To Time") - CreateDateTime(PerDiemCalculation.Date, PerDiemCalculation."From Time");
        //PerDiemCalculation."Day Duration" := PerDiemCalculation."Duration Integer" / (1000 * 60 * 60), 1, '>'); //1000msec * 60sec * 60min = hours
        PerDiemCalculation.Insert(true);
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
}
