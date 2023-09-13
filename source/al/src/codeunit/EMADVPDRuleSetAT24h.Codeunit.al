codeunit 62089 "EMADV PD Rule Set AT 24h" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        SetupPerDiemCalculationTable(PerDiem, PerDiemDetail);
    end;

    local procedure SetupPerDiemCalculationTable(var PerDiem: Record "CEM Per Diem"; var CurrPerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        CurrCountry: Code[10];
        NextDayDateTime: DateTime;
    begin
        // This procedure is only used on the first per diem detail entry
        if CurrPerDiemDetail."Entry No." > 1 then
            exit;

        if not EMSetup.Get() then
            exit;

        ResetPerDiemCalculation(PerDiem);

        //Create 1st day >>>
        //24h rule 
        NextDayDateTime := AddDayToDT(PerDiem."Departure Date/Time");
        //By Day rule 
        //NextDayDateTime := CreateDateTime(DT2Date(PerDiem."Departure Date/Time") + 1, 000000T);

        CurrCountry := PerDiem."Departure Country/Region";
        InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiem."Departure Date/Time", NextDayDateTime, CurrCountry, false);
        //Create 1st day <<<

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then
            repeat
                if not AddPerDiemDestToCalc(PerDiem, PerDiemDetail, PerDiemCalculation, NextDayDateTime, CurrCountry) then begin
                    // not on the first day
                    if (PerDiemDetail.Date > DT2Date(PerDiem."Departure Date/Time")) then begin
                        // Return on the same date and return date is smaller than next day date
                        if (PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time")) then begin
                            if PerDiemCalculation."To DateTime" > PerDiem."Return Date/Time" then begin
                                UpdateCalcWithToDT(PerDiemCalculation, PerDiem."Return Date/Time");
                            end else begin
                                NextDayDateTime := PerDiem."Return Date/Time";
                                InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", PerDiem."Return Date/Time", CurrCountry, true);
                            end;
                        end else begin
                            NextDayDateTime := AddDayToDT(NextDayDateTime);
                            InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true);
                        end;
                    end;
                end;
            until PerDiemDetail.Next() = 0;

        CalculateATPerDiemTwelth(PerDiem, PerDiemDetail);
    end;

    local procedure AddPerDiemDestToCalc(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalculation: Record "EMADV Per Diem Calculation"; var NextDayDateTime: DateTime; var CurrCountry: Code[10]): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemDetailDest: Record "CEM Per Diem Detail Dest.";
    begin
        if not EMSetup.Get() then
            exit;

        if not EMSetup."Enable Per Diem Destinations" then
            exit;

        PerDiemDetailDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemDetailDest.SetRange("Per Diem Detail Entry No.", PerDiemDetail."Entry No.");
        if PerDiemDetailDest.IsEmpty() then
            exit;

        PerDiemDetailDest.FindSet();
        repeat
            // Check if we have to log a new day till destination arrival
            if NextDayDateTime < CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time") then begin
                NextDayDateTime := AddDayToDT(NextDayDateTime);
                InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true);
            end;

            // track begin of foreign country
            if (PerDiemDetailDest."Destination Country/Region" <> PerDiem."Departure Country/Region") and
                (CurrCountry = PerDiem."Departure Country/Region") then begin

                NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, PerDiemDetailDest."Arrival Time");
            end;
            if NextDayDateTime > PerDiem."Return Date/Time" then
                NextDayDateTime := PerDiem."Return Date/Time";

            CurrCountry := PerDiemDetailDest."Destination Country/Region";
            //CurrCountry := PerDiemDetailDest."Destination Country/Region";
            InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time"), NextDayDateTime, CurrCountry, true)
        until PerDiemDetailDest.Next() = 0;
        exit(true);
    end;

    local procedure UpdateCalcWithToDT(var PerDiemCalculation: Record "EMADV Per Diem Calculation"; ToDateTime: DateTime)
    begin
        PerDiemCalculation.Validate("To DateTime", ToDateTime);
        PerDiemCalculation.Modify(true);
    end;

    local procedure InsertCalc(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalc: Record "EMADV Per Diem Calculation"; FromDateTime: DateTime; ToDateTime: DateTime; CurrCountry: Code[10]; UpdateCurrCalcToDTWithNewFromDT: Boolean)
    var

    begin
        //Update last calulation ToDate with new FromDate
        if UpdateCurrCalcToDTWithNewFromDT then
            UpdateCalcWithToDT(PerDiemCalc, FromDateTime);

        // Create new calculation record
        Clear(PerDiemCalc);
        PerDiemCalc.Validate("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemCalc."Per Diem Det. Entry No." := PerDiemDetail."Entry No.";
        PerDiemCalc."Entry No." := 0;
        PerDiemCalc.Validate("From DateTime", FromDateTime);
        PerDiemCalc.Validate("To DateTime", ToDateTime);
        PerDiemCalc.Validate("Country/Region", CurrCountry);
        PerDiemCalc.Insert(true);
    end;

    local procedure ResetPerDiemCalculation(var PerDiem: Record "CEM Per Diem")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if not PerDiemCalculation.IsEmpty then
            PerDiemCalculation.DeleteAll(true);
    end;

    local procedure AddDayToDT(BaseDateTime: DateTime): DateTime
    begin
        exit(CreateDateTime(DT2Date(BaseDateTime) + 1, DT2Time(BaseDateTime)));
    end;
}