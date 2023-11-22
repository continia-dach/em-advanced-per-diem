codeunit 62089 "EMADV PD Rule Set AT 24h" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemGroup: Record "CEM Per Diem Group";
    begin
        if not EMSetup.Get() then
            exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        PerDiemCalcRuleSet := PerDiemGroup."Calculation rule set";

        // Fill per diem calculation table
        SetupPerDiemCalculationTable(PerDiem, PerDiemDetail);

        // Calculate the Austrian twelth
        CalculateATPerDiemTwelth(PerDiem, PerDiemDetail);

        // Add the daily accommocation value
        SetDailyAllowances(PerDiem);

        // Calculate the reimbursement values  
        CalculateReimbursementAmounts(PerDiem);
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
        if not PerDiemDetail.Get(CurrPerDiemDetail."Per Diem Entry No.", CurrPerDiemDetail."Entry No.", CurrPerDiemDetail.Date) then
            exit;

        NextDayDateTime := GetNextDayTime(PerDiem."Departure Date/Time");

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
                            NextDayDateTime := GetNextDayTime(NextDayDateTime);
                            InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true);
                        end;
                    end;
                end;
            until PerDiemDetail.Next() = 0;


    end;

    local procedure CalculateATPerDiemTwelth(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        CurrDayTwelfth: Integer;
        CurrPerDiemDetEntry: Integer;
        Hours: Integer;
        NextDayDateTime: DateTime;
        LastCountry: Code[10];
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiem."Departure Country/Region" <> '' then
            PerDiemCalculation.SetFilter("Country/Region", '<>%1&<>%2', PerDiem."Departure Country/Region", PerDiem."Destination Country/Region");

        if PerDiemCalculation.IsEmpty then
            //sra 2030929 exit;
            PerDiemCalculation.SetRange("Country/Region");


        CurrPerDiemDetEntry := PerDiemDetail."Entry No.";

        if not PerDiemCalculation.FindSet() then
            exit;

        NextDayDateTime := GetNextDayTime(PerDiemCalculation."From DateTime");
        repeat
            if PerDiemCalculation."From DateTime" = NextDayDateTime then begin
                //if CurrPerDiemDetEntry <> PerDiemCalculation."Per Diem Det. Entry No." then begin
                CurrPerDiemDetEntry := PerDiemCalculation."Per Diem Det. Entry No.";
                CurrDayTwelfth := 0;
                NextDayDateTime := GetNextDayTime(NextDayDateTime);
            end;

            if LastCountry <> PerDiemCalculation."Country/Region" then
                CurrDayTwelfth := 0;

            Hours := Round(PerDiemCalculation."Day Duration" / (1000 * 60 * 60), 1, '>');
            if (Hours >= 12) then
                PerDiemCalculation."AT Per Diem Twelfth" := 12 - CurrDayTwelfth
            else
                PerDiemCalculation."AT Per Diem Twelfth" := Hours - CurrDayTwelfth;

            CurrDayTwelfth += PerDiemCalculation."AT Per Diem Twelfth";
            PerDiemCalculation.Modify();

            LastCountry := PerDiemCalculation."Country/Region";
        until PerDiemCalculation.Next() = 0;
    end;

    local procedure SetDailyAllowances(var PerDiem: Record "CEM Per Diem")
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then
            repeat
                PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                if PerDiemCalculation.FindSet() then
                    repeat
                        if PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, PerDiemCalculation."Country/Region", CustPerDiemRate."Calculation Method"::FullDay) then begin
                            PerDiemCalculation."Daily Accommodation Allowance" := CustPerDiemRate."Daily Accommodation Allowance";
                            PerDiemCalculation."Daily Meal Allowance" := CustPerDiemRate."Daily Meal Allowance";
                            PerDiemCalculation.Modify();
                        end;
                    until PerDiemCalculation.Next() = 0;
            until PerDiemDetail.Next() = 0;
    end;

    local procedure CalculateReimbursementAmounts(var PerDiem: Record "CEM Per Diem")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemGroup: Record "CEM Per Diem Group";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        RemainingTwelth: Integer;
        TotalReimbursedTwelth: Integer;
        RemainingDomesticTwelth: Integer;
    begin
        if PerDiem."Entry No." = 0 then
            exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then begin
            PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
            PerDiemCalculation.SetFilter("AT Per Diem Twelfth", '>0');
            case PerDiemGroup."Preferred rate" of
                "EMADV Per Diem Preferred Rates"::Highest:
                    begin
                        PerDiemCalculation.SetCurrentKey("Daily Meal Allowance");
                        PerDiemCalculation.Ascending(false);
                    end;
                "EMADV Per Diem Preferred Rates"::First:
                    begin
                        PerDiemCalculation.Ascending(true);
                    end;
                "EMADV Per Diem Preferred Rates"::Last:
                    begin
                        PerDiemCalculation.Ascending(false);
                    end;
            end;

            repeat
                RemainingTwelth := 12;
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                if PerDiemCalculation.FindSet() then
                    repeat
                        if RemainingTwelth = 0 then begin
                            PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := 0;
                        end else begin
                            if PerDiemCalculation."AT Per Diem Twelfth" > RemainingTwelth then begin
                                PerDiemCalculation."Meal Reimb. Amount" := PerDiemCalculation."Daily Meal Allowance" / 12 * RemainingTwelth;
                                PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := RemainingTwelth;
                                RemainingTwelth := 0;
                            end else begin
                                PerDiemCalculation."Meal Reimb. Amount" := PerDiemCalculation."Daily Meal Allowance" / 12 * PerDiemCalculation."AT Per Diem Twelfth";
                                PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := PerDiemCalculation."AT Per Diem Twelfth";
                                RemainingTwelth -= PerDiemCalculation."AT Per Diem Twelfth";
                            end;
                        end;
                        PerDiemCalculation.Modify();
                        TotalReimbursedTwelth += PerDiemCalculation."AT Per Diem Reimbursed Twelfth";
                    until PerDiemCalculation.Next() = 0;
            until PerDiemDetail.Next() = 0;

            RemainingDomesticTwelth := PerDiemCalcMgt.GetTripDurationInTwelth(PerDiem) - TotalReimbursedTwelth;
            if RemainingDomesticTwelth > 0 then begin
                //Calculate remaining twelth and reimbursement amount for domestic time
                PerDiemCalculation.Reset();
                PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                if PerDiemCalculation.FindLast() then begin
                    PerDiemCalculation."Meal Reimb. Amount" := PerDiemCalculation."Daily Meal Allowance" / 12 * (RemainingDomesticTwelth);
                    PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := RemainingDomesticTwelth;
                    PerDiemCalculation.Modify();
                end;
            end;
        end;
    end;

    internal procedure GetTwelfth(FromDateTime: DateTime; ToDateTime: DateTime): Integer
    var
        myInt: Integer;
    begin
        myInt := (ToDateTime - FromDateTime) / (1000 * 60 * 60);
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
                NextDayDateTime := GetNextDayTime(NextDayDateTime);
                InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true);
            end;

            // track begin of foreign country
            if (PerDiemDetailDest."Destination Country/Region" <> PerDiem."Departure Country/Region") and
                (CurrCountry = PerDiem."Departure Country/Region") then begin

                case PerDiemCalcRuleSet of
                    "EMADV Per Diem Calc. Rule Set"::Austria24h:
                        NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, PerDiemDetailDest."Arrival Time");
                    "EMADV Per Diem Calc. Rule Set"::AustriaByDay:
                        NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, 000000T);
                end;
            end;
            if NextDayDateTime > PerDiem."Return Date/Time" then
                NextDayDateTime := PerDiem."Return Date/Time";

            CurrCountry := PerDiemDetailDest."Destination Country/Region";

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

    local procedure GetNextDayTime(BaseDateTime: DateTime): DateTime
    begin
        case PerDiemCalcRuleSet of
            "EMADV Per Diem Calc. Rule Set"::Austria24h:
                exit(CreateDateTime(DT2Date(BaseDateTime) + 1, DT2Time(BaseDateTime)));
            "EMADV Per Diem Calc. Rule Set"::AustriaByDay:
                exit(CreateDateTime(DT2Date(BaseDateTime) + 1, 000000T));
            else
                //TODO Find out if we need another default calculation and in case which one is needed
                exit(BaseDateTime);
        end;
    end;

    var
        PerDiemCalcRuleSet: enum "EMADV Per Diem Calc. Rule Set";
}