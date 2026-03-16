codeunit 62085 "EMADV PD Rule Set KVMetal" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemGroup: Record "CEM Per Diem Group";
    begin
        PerDiemCalcMgt.ResetPerDiemCalculation(PerDiem);

        // we only calculate on first entry
        if (PerDiemDetail."Entry No." <> 1) then
            exit;

        if not EMSetup.Get() then
            exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        PerDiemCalcRuleSet := PerDiemGroup."Calculation rule set";

        // Fill per diem calculation table
        SetupPerDiemCalculationTable(PerDiem, PerDiemGroup, PerDiemDetail);

        // Add the daily accommocation value
        CalculateAllowances(PerDiem, PerDiemGroup);

        // Calculate the reimbursement values  
        CalculateReimbursementAmounts(PerDiem, PerDiemGroup);

        // Iterate and update new per diem details 
        UpdatePerDiemDetails(PerDiem);

        exit(true);
    end;

    internal procedure UpdatePerDiemDetails(PerDiem: Record "CEM Per Diem")
    var
        PerDiemDetail: record "CEM Per Diem Detail";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet(true) then
            repeat
                UpdatePerDiemDetail(PerDiem, PerDiemDetail);
            until PerDiemDetail.Next() = 0;
    end;

    /// <summary>
    /// Calculates the reimbursement amounts of the current per diem record and writes them back to the Per Diem Calculation table
    /// </summary>
    local procedure CalculateReimbursementAmounts(PerDiem: Record "CEM Per Diem"; PerDiemGroup: Record "CEM Per Diem Group")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then begin
            PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
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

            // Handling foreign part of per diem
            // if PerDiemWithMultipleDestinations(PerDiem) then
            //     PerDiemCalculation.SetRange("Domestic Entry", false);

            repeat
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                if PerDiemCalculation.FindFirst() then begin
                    PerDiemCalculation."Meal Reimb. Amount" := PerDiemCalculation."Daily Meal Allowance";
                    PerDiemCalculation."Meal Reimb. Amount taxable" := PerDiemCalculation."Daily Meal Allowance taxable";
                    PerDiemCalculation.Modify();
                end;
            until PerDiemDetail.Next() = 0;

            // Handling domestic part of per diem
            if PerDiemWithMultipleDestinations(PerDiem) then begin
                PerDiemCalculation.SetRange("AT Per Diem Twelfth");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.");
                PerDiemCalculation.SetRange("Domestic Entry", true);

            end;
        end;
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


    local procedure CalculateAllowances(PerDiem: Record "CEM Per Diem"; PerDiemGroup: Record "CEM Per Diem Group")
    var

        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemRate: Record "CEM Per Diem Rate v.2";
        PerDiemSubRate: Record "CEM Per Diem Rate Details v.2";
        NewDay: Boolean;
    begin
        // Check minimum stay
        if PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            if PerDiemGroup."Minimum Stay (hours)" > 0 then begin
                if PerDiemCalcMgt.GetTripDurationInHours(PerDiem, 1, '<') < PerDiemGroup."Minimum Stay (hours)" then begin
                    //TODO Add comments, unfortunately protected
                    //ExpCmtMgt.AddComment(DATABASE::"CEM Per Diem", 0, '', PerDiem."Entry No.",
                    //EMComment.Importance::Error, 'NO EMPLOYEE', STRSUBSTNO(FieldMissing, PerDiem.FIELDCAPTION("Continia User ID")), TRUE);
                    exit;
                end;

            end;


        // Iterate through each day/detail 
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then
            repeat
                // New day is used to activate the accommodation allowance for the first part
                NewDay := true;

                PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
                if PerDiemCalculation.FindSet() then
                    repeat
                        // Search per diem date and update calculation record
                        GetValidPerDiemRate(PerDiem, PerDiemDetail, PerDiemCalculation, NewDay);

                        // Reset NewDay as it can only be used on the first record of the day
                        NewDay := false;
                    until PerDiemCalculation.Next() = 0;
            until PerDiemDetail.Next() = 0;
    end;

    local procedure GetValidPerDiemRate(PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalc: Record "EMADV Per Diem Calculation"; NewDay: Boolean): Boolean
    var
        PerDiemRate: Record "CEM Per Diem Rate v.2";
        PerDiemSubRate: Record "CEM Per Diem Rate Details v.2";
    begin
        // Find per Diem Rate first
        PerDiemRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");

        // if an entry is marked as domestic entry, we change the destination country temporary for filtering
        if PerDiemCalc."Domestic Entry" then
            PerDiemRate.SetRange("Destination Country/Region", PerDiem."Departure Country/Region")
        else
            PerDiemRate.SetRange("Destination Country/Region", PerDiemCalc."Country/Region");

        PerDiemRate.SetFilter("Start Date", '..%1', PerDiemDetail.Date);
        if PerDiemRate.IsEmpty then
            exit;

        if PerDiemRate.FindLast() then begin
            // Set the daily allowance
            //PerDiemCalc."Daily Meal Allowance" := PerDiemRate."Daily Meal Allowance";

            // Set the accommodation allowance, if it's the first day entry and not on the first day

            if PerDiemCalcMgt.GetTripDurationInHours(PerDiem, 1, '<') >= 6 then begin
                // One day stay
                if DT2Date(PerDiem."Departure Date/Time") = DT2Date(PerDiem."Return Date/Time") then begin
                    if PerDiemCalcMgt.GetTripDurationInHours(PerDiem, 1, '<') < 11 then begin
                        PerDiemCalc."Daily Meal Allowance" := PerDiemRate."Day trip from 6h";
                        PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."Day trip from 6h taxable";
                    end else begin
                        PerDiemCalc."Daily Meal Allowance" := PerDiemRate."Day trip from 11h";
                        PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."Day trip from 11h taxable";
                    end;
                end else begin
                    // First Day
                    if PerDiemCalcMgt.IsFirstDay(PerDiem, PerDiemDetail) then begin
                        if DT2Time(PerDiem."Departure Date/Time") < 120000T then begin
                            PerDiemCalc."Daily Meal Allowance" := PerDiemRate."O/N trip dep. pre 12pm";
                            PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."O/N trip dep. pre 12pm taxable";
                        end else begin
                            PerDiemCalc."Daily Meal Allowance" := PerDiemRate."O/N trip dep. after 12pm";
                            PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."O/N trip dep. after 12pm tax.";
                        end;
                    end else if PerDiemCalcMgt.IsLastDay(PerDiem, PerDiemDetail) then begin
                        // Last Day
                        if DT2Time(PerDiem."Return Date/Time") < 170000T then begin
                            PerDiemCalc."Daily Meal Allowance" := PerDiemRate."O/N trip arr. before 5pm";
                            PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."O/N trip arr. before 5pm tax.";
                        end else begin
                            PerDiemCalc."Daily Meal Allowance" := PerDiemrate."O/N trip arr. after 5pm";
                            PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."O/N trip arr. after 5pm tax.";
                        end;
                    end else begin
                        // Full day
                        PerDiemCalc."Daily Meal Allowance" := PerDiemRate."O/N trip full day";
                        PerDiemCalc."Daily Meal Allowance taxable" := PerDiemRate."O/N trip full day taxable";
                    end;
                end;
                /*
                                if (not PerDiemCalcMgt.IsFirstDay(PerDiem, PerDiemDetail)) and
                                   (NewDay)
                                then begin
                                    PerDiemCalc."Daily Accommodation Allowance" := PerDiemRate."Daily Accommodation Allowance";
                                end;
                                */
            end;


            //PerDiemCalc."Meal Reimb. Amount" := PerDiemCalc."Daily Meal Allowance";
            //PerDiemCalc."Meal Reimb. Amount taxable" := PerDiemCalc."Daily Meal Allowance taxable";
            PerDiemCalc.Modify();
        end;
    end;

    local procedure SetupPerDiemCalculationTable(PerDiem: Record "CEM Per Diem"; PerDiemGroup: Record "CEM Per Diem Group"; CurrPerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        CurrentCountry: Record "CEM Country/Region";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetail: Record "CEM Per Diem Detail";
        NextDayDateTime: DateTime;
        ForeignCountryDuration: Duration;
    begin
        // This procedure is only used on the first per diem detail entry
        if CurrPerDiemDetail."Entry No." > 1 then
            exit;

        if not EMSetup.Get() then
            exit;

        if not CurrentCountry.Get(PerDiem."Departure Country/Region") then
            exit;

        // Delete existing calculations
        PerDiemCalcMgt.ResetPerDiemCalculation(PerDiem);

        //Create 1st day >>>
        if not PerDiemDetail.Get(CurrPerDiemDetail."Per Diem Entry No.", CurrPerDiemDetail."Entry No.", CurrPerDiemDetail.Date) then
            exit;

        NextDayDateTime := GetNextDayTime(PerDiem."Departure Date/Time");
        if PerDiem."Return Date/Time" < NextDayDateTime then
            NextDayDateTime := PerDiem."Return Date/Time";

        PerDiemCalcMgt.InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiem."Departure Date/Time", NextDayDateTime, CurrentCountry, false);
        //Create 1st day <<<

        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindSet() then begin
            repeat
                // Either there are multiple destination linked to one per diem detail or not
                // Try to process the multiple destinations first and if not found then process the current destination
                if not AddDestinationToCalculation(PerDiem, PerDiemDetail, PerDiemCalculation, NextDayDateTime, CurrentCountry) then begin
                    // not on the first day
                    if (PerDiemDetail.Date > DT2Date(PerDiem."Departure Date/Time")) then begin
                        // Return on the same date and return date is smaller than next day date
                        if (PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time")) then begin
                            if PerDiemCalculation."To DateTime" > PerDiem."Return Date/Time" then
                                PerDiemCalcMgt.UpdateCalcWithToDT(PerDiemCalculation, PerDiem."Return Date/Time")
                            else begin
                                NextDayDateTime := PerDiem."Return Date/Time";
                                PerDiemCalcMgt.InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", PerDiem."Return Date/Time", CurrentCountry, true);
                            end;
                        end else begin
                            NextDayDateTime := GetNextDayTime(NextDayDateTime);
                            PerDiemCalcMgt.InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrentCountry, true);
                        end;
                    end;
                end;
            until PerDiemDetail.Next() = 0;

            PerDiemCalculation.Modify();
        end;

        // Check if duration of foreign country part is less then allowed to be marked as foreign
        if PerDiemGroup."Min. Stay Foreign ctry. (h)" = 0 then
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
        if PerDiemCalcMgt.ConvertMsecDurationIntoHours(ForeignCountryDuration, 0.1, '>') < PerDiemGroup."Min. Stay Foreign ctry. (h)" then
            PerDiemCalculation.ModifyAll("Domestic Entry", true);
    end;

    local procedure AddDestinationToCalculation(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalculation: Record "EMADV Per Diem Calculation"; var NextDayDateTime: DateTime; var CurrentCountry: Record "CEM Country/Region"): Boolean
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
                PerDiemCalcMgt.InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, PerDiemCalculation."To DateTime", NextDayDateTime, CurrentCountry, true);
            end;

            // track begin of foreign country
            if (PerDiemDetailDest."Destination Country/Region" <> PerDiem."Departure Country/Region") and
                (CurrentCountry.Code = PerDiem."Departure Country/Region") then begin

                case PerDiemCalcRuleSet of
                    "EMADV Per Diem Calc. Rule Set"::Austria24h:
                        NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, PerDiemDetailDest."Arrival Time");
                    "EMADV Per Diem Calc. Rule Set"::AustriaByDay:
                        NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, 000000T);
                    "EMADV Per Diem Calc. Rule Set"::KVMetallgewerbe:
                        NextDayDateTime := CreateDateTime(PerDiemDetail.Date + 1, 000000T);
                end;
            end;
            if NextDayDateTime > PerDiem."Return Date/Time" then
                NextDayDateTime := PerDiem."Return Date/Time";

            CurrentCountry.Get(PerDiemDetailDest."Destination Country/Region");

            PerDiemCalcMgt.InsertCalc(PerDiem, PerDiemDetail, PerDiemCalculation, CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time"), NextDayDateTime, CurrentCountry, true);
        until PerDiemDetailDest.Next() = 0;
        exit(true);
    end;

    //TODO Move to calc mgt if possible
    internal procedure GetNextDayTime(BaseDateTime: DateTime): DateTime
    begin
        case PerDiemCalcRuleSet of
            "EMADV Per Diem Calc. Rule Set"::Austria24h:
                exit(CreateDateTime(DT2Date(BaseDateTime) + 1, DT2Time(BaseDateTime)));
            "EMADV Per Diem Calc. Rule Set"::AustriaByDay:
                exit(CreateDateTime(DT2Date(BaseDateTime) + 1, 000000T));
            "EMADV Per Diem Calc. Rule Set"::KVMetallgewerbe:
                exit(CreateDateTime(DT2Date(BaseDateTime) + 1, 000000T));
            else
                //TODO Find out if we need another default calculation and in case which one is needed
                exit(BaseDateTime);
        end;
    end;

    internal procedure UpdatePerDiemDetail(PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        Currency: Record Currency;
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        MealAllowanceDeductionAmt: Decimal;
    begin
        if (not (PerDiem.Status in [PerDiem.Status::Open, PerDiem.Status::Released])) or (PerDiem.Posted = true) then
            exit;

        // Clear old values >>>
        Clear(MealAllowanceDeductionAmt);
        Clear(PerDiemDetail."Accommodation Allowance Amount");
        Clear(PerDiemDetail."Meal Allowance Amount");
        Clear(PerDiemDetail."Taxable Acc. Allowance Amount");
        Clear(PerDiemDetail."Taxable Meal Allowance Amount");
        Clear(PerDiemDetail."Taxable Amount");
        Clear(PerDiemDetail."Taxable Amount (LCY)");

        // Filter calculation table and fill details amount fields
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiemDetail."Per Diem Entry No.");
        PerDiemCalculation.SetRange("Per Diem Det. Entry No.", PerDiemDetail."Entry No.");
        PerDiemCalculation.SetRange("From DateTime", CreateDateTime(PerDiemDetail.Date, 000000T), CreateDateTime(PerDiemDetail.Date, 235959T));
        if PerDiemCalculation.FindSet() then
            repeat
                // Transfer calculation meal allowance amount
                //PerDiemDetail."Meal Allowance Amount" += PerDiemCalculation."Meal Reimb. Amount";
                PerDiemDetail."Meal Allowance Amount" += PerDiemCalculation."Meal Reimb. Amount" + PerDiemCalculation."Meal Reimb. Amount taxable";
                PerDiemDetail."Taxable Meal Allowance Amount" += PerDiemCalculation."Meal Reimb. Amount taxable";

            /*
            // Transfer the accommodation allowance amount
            if PerDiemDetail."Accommodation Allowance" and (PerDiemCalculation."Daily Accommodation Allowance" <> 0) then begin
                PerDiemDetail.Validate("Accommodation Allowance Amount", PerDiemCalculation."Daily Accommodation Allowance");
                PerDiemCalculation.Validate("Accommodation Reimb. Amount", PerDiemDetail."Accommodation Allowance Amount");
            end else
                PerDiemCalculation.Validate("Accommodation Reimb. Amount", 0);
            PerDiemCalculation.Modify(false);
            */
            until PerDiemCalculation.Next() = 0;


        // Final calculation of total reimbursement amounts
        PerDiemDetail."Taxable Amount" := PerDiemDetail."Taxable Meal Allowance Amount" + PerDiemDetail."Taxable Acc. Allowance Amount";

        PerDiemDetail.Amount := ROUND(PerDiemDetail."Accommodation Allowance Amount" + PerDiemDetail."Meal Allowance Amount" + PerDiemDetail."Transport Allowance Amount" +
              PerDiemDetail."Entertainment Allowance Amount" + PerDiemDetail."Drinks Allowance Amount", Currency."Amount Rounding Precision");

        PerDiemDetail."Amount (LCY)" := PerDiemDetail.Amount; // TODO: Set up LCY calculation
        PerDiemDetail."Taxable Amount (LCY)" := PerDiemDetail."Taxable Amount";

        PerDiemDetail.Modified := true;

        // Save updated detail record
        exit(PerDiemDetail.Modify());
    end;

    var
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        PerDiemCalcRuleSet: enum "EMADV Per Diem Calc. Rule Set";
}
