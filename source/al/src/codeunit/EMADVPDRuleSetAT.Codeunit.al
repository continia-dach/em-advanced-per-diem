codeunit 62084 "EMADV PD Rule Set AT" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemGroup: Record "CEM Per Diem Group";

        PerDiemDetailUpdate: record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        Currency: Record Currency;
    begin
        // we only calculate on first entry
        if (PerDiemDetail."Entry No." <> 1) then
            exit;

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
        SetDailyAllowancesAndDeductions(PerDiem);

        // Calculate the reimbursement values  
        CalculateReimbursementAmounts(PerDiem);

        // Iterate and update new diem details 
        PerDiemDetailUpdate.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetailUpdate.FindSet(true) then
            repeat
                // Clear old values >>>
                Clear(PerDiemDetailUpdate."Accommodation Allowance Amount");
                Clear(PerDiemDetailUpdate."Meal Allowance Amount");
                Clear(PerDiemDetailUpdate."Transport Allowance Amount");
                Clear(PerDiemDetailUpdate."Entertainment Allowance Amount");
                Clear(PerDiemDetailUpdate."Drinks Allowance Amount");

                Clear(PerDiemDetailUpdate."Taxable Acc. Allowance Amount");
                Clear(PerDiemDetailUpdate."Taxable Meal Allowance Amount");
                Clear(PerDiemDetailUpdate."Taxable Amount");
                Clear(PerDiemDetailUpdate."Taxable Amount (LCY)");

                // Get fill calculation table and fill amount fields
                PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetailUpdate."Entry No.");
                PerDiemCalculation.SetRange("From DateTime", CreateDateTime(PerDiemDetailUpdate.Date, 000000T), CreateDateTime(PerDiemDetailUpdate.Date, 235959T));
                if PerDiemCalculation.FindSet() then
                    repeat
                        if PerDiemCalculation."Meal Allowance Deductions" <= PerDiemCalculation."Meal Reimb. Amount" then
                            PerDiemDetailUpdate."Meal Allowance Amount" += PerDiemCalculation."Meal Reimb. Amount" - PerDiemCalculation."Meal Allowance Deductions";
                        PerDiemDetailUpdate."Accommodation Allowance Amount" += PerDiemCalculation."Accommodation Reimb. Amount";
                    until PerDiemCalculation.Next() = 0;

                PerDiemDetailUpdate.Amount := ROUND(PerDiemDetailUpdate."Accommodation Allowance Amount" + PerDiemDetailUpdate."Meal Allowance Amount" + PerDiemDetailUpdate."Transport Allowance Amount" +
                      PerDiemDetailUpdate."Entertainment Allowance Amount" + PerDiemDetailUpdate."Drinks Allowance Amount", Currency."Amount Rounding Precision");
                PerDiemDetailUpdate."Amount (LCY)" := PerDiemDetailUpdate.Amount; // TODO: Set up LCY calculation
                PerDiemDetailUpdate.Modify();
            until PerDiemDetailUpdate.Next() = 0;
    end;


    local procedure SetupPerDiemCalculationTable(var PerDiem: Record "CEM Per Diem"; var CurrPerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemGroup: Record "CEM Per Diem Group";
        CurrCountry: Code[10];
        NextDayDateTime: DateTime;
        ForeignCountryDuration: Duration;
    begin
        // This procedure is only used on the first per diem detail entry
        if CurrPerDiemDetail."Entry No." > 1 then
            exit;

        if not EMSetup.Get() then
            exit;

        // Delete existing calculations
        ResetPerDiemCalculation(PerDiem);

        //Create 1st day >>>
        if not PerDiemDetail.Get(CurrPerDiemDetail."Per Diem Entry No.", CurrPerDiemDetail."Entry No.", CurrPerDiemDetail.Date) then
            exit;

        NextDayDateTime := GetNextDayTime(PerDiem."Departure Date/Time");
        if PerDiem."Return Date/Time" < NextDayDateTime then
            NextDayDateTime := PerDiem."Return Date/Time";

        CurrCountry := PerDiem."Departure Country/Region";
        InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiem."Departure Date/Time", NextDayDateTime, CurrCountry, false, true);
        //Create 1st day <<<

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then begin
            repeat
                // Either there are multiple destination linked to one per diem detail or not
                // Try to process the multiple destinations first and if not found then process the current destination
                if not AddPerDiemDestToCalc(PerDiem, PerDiemDetail, PerDiemCalculation, NextDayDateTime, CurrCountry) then begin
                    // not on the first day
                    if (PerDiemDetail.Date > DT2Date(PerDiem."Departure Date/Time")) then begin
                        // Return on the same date and return date is smaller than next day date
                        if (PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time")) then begin
                            if PerDiemCalculation."To DateTime" > PerDiem."Return Date/Time" then
                                UpdateCalcWithToDT(PerDiemCalculation, PerDiem."Return Date/Time")
                            else begin
                                NextDayDateTime := PerDiem."Return Date/Time";
                                InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", PerDiem."Return Date/Time", CurrCountry, true, false);
                            end;
                        end else begin
                            NextDayDateTime := GetNextDayTime(NextDayDateTime);
                            InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true, false);
                        end;
                    end;
                end;
            until PerDiemDetail.Next() = 0;

            // Mark last entry as "Domestic entry"
            PerDiemCalculation."Domestic Entry" := true;
            PerDiemCalculation.Modify();
        end;

        // Check if duration of foreign country part is less then allowed to be marked as foreign
        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        if PerDiemGroup."Min. foreign country duration" = 0 then
            exit;

        PerDiemCalculation.Reset();
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemCalculation.SetFilter("Country/Region", '<>%1', PerDiem."Departure Country/Region");
        if PerDiemCalculation.IsEmpty() then
            exit;
        if PerDiemCalculation.FindSet() then
            repeat
                ForeignCountryDuration += PerDiemCalculation."Day Duration";
            until PerDiemCalculation.Next() = 0;
        if PerDiemCalcMgt.ConvertMsecDurationIntoHours(ForeignCountryDuration) < PerDiemGroup."Min. foreign country duration" then
            PerDiemCalculation.ModifyAll("Domestic Entry", true);
    end;

    local procedure CalculateATPerDiemTwelth(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        CurrDayTwelfth: Integer;
        CurrPerDiemDetEntry: Integer;
        TotalTwelthToReimburse: Integer;
        RemainingDomesticTwelth: Integer;
        Hours: Integer;
        NextDayDateTime: DateTime;
        LastCountry: Code[10];
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemWithMultipleDestinations(PerDiem) then
            //if PerDiem."Departure Country/Region" <> '' then
            PerDiemCalculation.SetRange("Domestic Entry", false);

        //if PerDiem."Departure Country/Region" <> '' then
        //    PerDiemCalculation.SetFilter("Country/Region", '<>%1&<>%2', PerDiem."Departure Country/Region", PerDiem."Destination Country/Region");

        if PerDiemCalculation.IsEmpty then
            PerDiemCalculation.SetRange("Country/Region");

        CurrPerDiemDetEntry := PerDiemDetail."Entry No.";

        if not PerDiemCalculation.FindSet() then
            exit;

        NextDayDateTime := GetNextDayTime(PerDiemCalculation."From DateTime");
        repeat
            if PerDiemCalculation."From DateTime" = NextDayDateTime then begin
                CurrPerDiemDetEntry := PerDiemCalculation."Per Diem Det. Entry No.";
                CurrDayTwelfth := 0;
                NextDayDateTime := GetNextDayTime(NextDayDateTime);
            end;

            if LastCountry <> PerDiemCalculation."Country/Region" then
                CurrDayTwelfth := 0;

            Hours := PerDiemCalcMgt.ConvertMsecDurationIntoHours(PerDiemCalculation."Day Duration");// / (1000 * 60 * 60), 1, '>');

            if (Hours >= 12) then
                PerDiemCalculation."AT Per Diem Twelfth" := 12 - CurrDayTwelfth
            else
                PerDiemCalculation."AT Per Diem Twelfth" := Hours - CurrDayTwelfth;

            CurrDayTwelfth += PerDiemCalculation."AT Per Diem Twelfth";
            TotalTwelthToReimburse += PerDiemCalculation."AT Per Diem Twelfth";
            PerDiemCalculation.Modify();

            LastCountry := PerDiemCalculation."Country/Region";
        until PerDiemCalculation.Next() = 0;
    end;

    local procedure SetDailyAllowancesAndDeductions(var PerDiem: Record "CEM Per Diem")
    var
        //CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemRate: Record "CEM Per Diem Rate v.2";
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then
            repeat
                PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                if PerDiemCalculation.FindSet() then
                    repeat
                        if PerDiemCalcMgt.GetValidPerDiemRate(PerDiemRate, PerDiemDetail, PerDiem, PerDiemCalculation) then begin
                            case true of
                                DT2Date(PerDiemCalculation."From DateTime") = DT2Date(PerDiem."Departure Date/Time"):
                                    begin
                                        if PerDiemDetail."Accommodation Allowance" then
                                            PerDiemCalculation."Daily Accommodation Allowance" := 0;
                                        PerDiemCalculation."Daily Meal Allowance" := PerDiemRate."First/Last Day Meal Allowance";
                                        PerDiemCalculation."Meal Allowance Deductions" := GetMaxDailyMealDeductions(PerDiemDetail, PerDiemRate, false);
                                    end;
                                (DT2Date(PerDiemCalculation."From DateTime") = DT2Date(PerDiem."Return Date/Time")):
                                    begin
                                        if PerDiemDetail."Accommodation Allowance" then
                                            PerDiemCalculation."Daily Accommodation Allowance" := PerDiemRate."Daily Accommodation Allowance";
                                        PerDiemCalculation."Daily Meal Allowance" := PerDiemRate."First/Last Day Meal Allowance";
                                        PerDiemCalculation."Meal Allowance Deductions" := GetMaxDailyMealDeductions(PerDiemDetail, PerDiemRate, false);
                                    end;
                                else begin
                                    if PerDiemDetail."Accommodation Allowance" then
                                        PerDiemCalculation."Daily Accommodation Allowance" := PerDiemRate."Daily Accommodation Allowance";
                                    PerDiemCalculation."Daily Meal Allowance" := PerDiemRate."Daily Meal Allowance";
                                    PerDiemCalculation."Meal Allowance Deductions" := GetMaxDailyMealDeductions(PerDiemDetail, PerDiemRate, true);
                                end;
                            end;

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

        RemainingTwelth: Integer;
        TotalReimbursedTwelth: Integer;
        RemainingDomesticTwelth: Integer;
        DomesticPartInHours: Integer;
        MaxTwelthOfDayToReimburse: Integer;
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
                CalculateAccommodationReimbursement(PerDiemDetail);
            until PerDiemDetail.Next() = 0;

            // Handling of domestic part >>>
            if PerDiemWithMultipleDestinations(PerDiem) then begin
                PerDiemCalculation.SetRange("AT Per Diem Twelfth");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.");
                PerDiemCalculation.SetRange("Domestic Entry", true);

                RemainingDomesticTwelth := PerDiemCalcMgt.GetTripDurationInTwelth(PerDiem) - TotalReimbursedTwelth;

                if RemainingDomesticTwelth > 0 then begin
                    if PerDiemCalculation.FindSet() then
                        repeat
                            DomesticPartInHours := PerDiemCalcMgt.ConvertMsecDurationIntoHours(PerDiemCalculation."Day Duration");
                            MaxTwelthOfDayToReimburse := GetMaxTwelthOfDayToReimburse(PerDiem."Entry No.", PerDiemCalculation."Per Diem Det. Entry No.");
                            if (MaxTwelthOfDayToReimburse > 0) then begin
                                if DomesticPartInHours >= MaxTwelthOfDayToReimburse then
                                    DomesticPartInHours := MaxTwelthOfDayToReimburse;

                                if DomesticPartInHours <= RemainingDomesticTwelth then begin
                                    PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := DomesticPartInHours;
                                    RemainingDomesticTwelth -= DomesticPartInHours;
                                end else begin
                                    if DomesticPartInHours >= 12 then begin
                                        PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := 12;
                                        //RemainingDomesticTwelth -= 12;
                                    end else begin
                                        PerDiemCalculation."AT Per Diem Reimbursed Twelfth" := RemainingDomesticTwelth;
                                        //RemainingDomesticTwelth := 0;
                                    end;
                                    RemainingDomesticTwelth := 0;
                                end;
                            end;
                            PerDiemCalculation."Meal Reimb. Amount" := PerDiemCalculation."Daily Meal Allowance" / 12 * (PerDiemCalculation."AT Per Diem Reimbursed Twelfth");
                            PerDiemCalculation.Modify(true);
                        until (PerDiemCalculation.Next() = 0) or (RemainingDomesticTwelth <= 0);
                end;
            end;
            // Handling of domestic part <<<
        end;
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
                InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrCountry, true, false);
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

            InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time"), NextDayDateTime, CurrCountry, true, false);
        until PerDiemDetailDest.Next() = 0;
        exit(true);
    end;


    local procedure UpdateCalcWithToDT(var PerDiemCalculation: Record "EMADV Per Diem Calculation"; ToDateTime: DateTime)
    begin
        PerDiemCalculation.Validate("To DateTime", ToDateTime);
        PerDiemCalculation.Modify(true);
    end;

    local procedure InsertCalc(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalc: Record "EMADV Per Diem Calculation"; FromDateTime: DateTime; ToDateTime: DateTime; CurrCountry: Code[10]; UpdateCurrCalcToDTWithNewFromDT: Boolean; FirstLastEntry: Boolean)
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
        PerDiemCalc.Validate("Domestic Entry", FirstLastEntry);
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

    local procedure GetMaxDailyMealDeductions(PerDiemDetail: Record "CEM Per Diem Detail"; PerDiemRate: Record "CEM Per Diem Rate v.2"; FullDay: Boolean): Decimal
    begin
        // Breakfast only
        if PerDiemDetail.Breakfast and (not PerDiemDetail.Lunch) and (not PerDiemDetail.Dinner) then
            if FullDay then
                exit(PerDiemRate."Full day Breakfast Ded.")
            else
                exit(PerDiemRate."Part day Breakfast Ded.");

        // Breakfast and lunch 
        if PerDiemDetail.Breakfast and PerDiemDetail.Lunch and (not PerDiemDetail.Dinner) then
            if FullDay then
                exit(PerDiemRate."Full day Breakfast-Lunch Ded.")
            else
                exit(PerDiemRate."Part day Breakfast-Lunch Ded.");

        // Breakfast and dinner
        if PerDiemDetail.Breakfast and (not PerDiemDetail.Lunch) and PerDiemDetail.Dinner then
            if FullDay then
                exit(PerDiemRate."Full day Breakfast-Dinner Ded.")
            else
                exit(PerDiemRate."Part day Breakfast-Dinner Ded.");

        // Lunch only
        if (not PerDiemDetail.Breakfast) and PerDiemDetail.Lunch and (not PerDiemDetail.Dinner) then
            if FullDay then
                exit(PerDiemRate."Full day Lunch Ded.")
            else
                exit(PerDiemRate."Part day Lunch Ded.");

        // Lunch and Dinner
        if (not PerDiemDetail.Breakfast) and PerDiemDetail.Lunch and PerDiemDetail.Dinner then
            if FullDay then
                exit(PerDiemRate."Full day Lunch-Dinner Ded.")
            else
                exit(PerDiemRate."Part day Lunch-Dinner Ded.");

        // Dinner only
        if (not PerDiemDetail.Breakfast) and (not PerDiemDetail.Lunch) and PerDiemDetail.Dinner then
            if FullDay then
                exit(PerDiemRate."Full day Dinner Ded.")
            else
                exit(PerDiemRate."Part day Dinner Ded.");

        // All meals
        if PerDiemDetail.Breakfast and PerDiemDetail.Lunch and PerDiemDetail.Dinner then
            if FullDay then
                exit(PerDiemRate."Full day All meal Ded.")
            else
                exit(PerDiemRate."Part day All meal Ded.");
    end;

    local procedure PerDiemWithMultipleDestinations(var PerDiem: Record "CEM Per Diem"): Boolean
    var
        PerDiemDestinations: Record "CEM Per Diem Detail Dest.";
    begin
        PerDiemDestinations.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        PerDiemDestinations.SetFilter("Destination Country/Region", '<>%1', PerDiem."Departure Country/Region");

        // return true if destination table is not empy 
        exit(not PerDiemDestinations.IsEmpty);
    end;

    local procedure GetMaxTwelthOfDayToReimburse(PerDiemEntryNo: Integer; PerDiemDetEntryNo: Integer) ReimbursedTwelthOfDay: Integer
    var
        //PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemGroup: Record "CEM Per Diem Group";
        PerDiem: Record "CEM Per Diem";
    begin
        if not PerDiem.Get(PerDiemEntryNo) then
            exit;
        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;
        if PerDiemGroup."Calculation rule set" = PerDiemGroup."Calculation rule set"::AustriaByDay then begin
            PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiemEntryNo);
            PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetEntryNo);
            if PerDiemCalculation.FindSet() then
                repeat
                    ReimbursedTwelthOfDay += PerDiemCalculation."AT Per Diem Reimbursed Twelfth";
                until PerDiemCalculation.Next() = 0;
        end;

        ReimbursedTwelthOfDay := 12 - ReimbursedTwelthOfDay;
    end;

    local procedure CalculateAccommodationReimbursement(PerDiemDetail: Record "CEM Per Diem Detail")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        IsHandled: Boolean;
    begin
        OnBeforeCalculateAccommodationReimbursement(PerDiemDetail, IsHandled);
        if IsHandled then
            exit;

        // Filter for first calculation (country) entry and use this as accommodation source
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiemDetail."Per Diem Entry No.");
        PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
        if PerDiemCalculation.FindFirst() then begin
            PerDiemCalculation."Accommodation Reimb. Amount" := PerDiemCalculation."Daily Accommodation Allowance";
            PerDiemCalculation.Modify(true);
        end;

        OnAfterCalculateAccommodationReimbursement(PerDiemDetail);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateAccommodationReimbursement(PerDiemDetail: Record "CEM Per Diem Detail"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateAccommodationReimbursement(PerDiemDetail: Record "CEM Per Diem Detail")
    begin
    end;


    var
        PerDiemCalcRuleSet: enum "EMADV Per Diem Calc. Rule Set";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
}