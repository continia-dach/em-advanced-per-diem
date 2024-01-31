codeunit 62081 "EMADV Cust. Per Diem Calc.Mgt."
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CEM Per Diem Calc. Engine", OnBeforeFindRateAndUpdateAmtOnDetail, '', false, false)]
    local procedure PerDiemCalcEngine_OnBeforeFindRateAndUpdateAmtOnDetail(var PerDiemDetails: Record "CEM Per Diem Detail"; var IsHandled: Boolean)
    begin
        IsHandled := CalcCustPerDiemRate(PerDiemDetails);
    end;

    internal procedure CalcCustPerDiemRate(var PerDiemDetail: Record "CEM Per Diem Detail") CalculationResult: Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiem: Record "CEM Per Diem";
        PerDiemGroup: Record "CEM Per Diem Group";
        Currency: Record Currency;
        PerDiemRuleSetProvider: Interface "EMADV IPerDiemRuleSetProvider";
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetailUpdate: Record "CEM Per Diem Detail";
    begin
        if not EMSetup.Get() then
            exit;
        if not EMSetup."Use Custom Per Diem Engine" then
            exit;

        if not PerDiem.Get(PerDiemDetail."Per Diem Entry No.") then
            exit;

        if (PerDiem."Departure Date/Time" = 0DT) or (PerDiem."Return Date/Time" = 0DT) then
            exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        // Recalculation and update of reimbursement amounts only on first record until we are sure, that we do it only once
        if PerDiemDetail."Entry No." <> 1 then
            exit(true);

        PerDiemRuleSetProvider := PerDiemGroup."Calculation rule set";
        PerDiemRuleSetProvider.CalcPerDiemRate(PerDiem, PerDiemDetail);

        // Copied from Standard >>>
        /* TODO add field Currency Code to cust per diem rates
        "Currency Code" := PerDiemRate."Currency Code";
        IF "Currency Code" <> '' THEN BEGIN
            CurrencyFactor := CurrExchRate.ExchangeRate(PostingDate, "Currency Code");
            Currency.GET("Currency Code");
            Currency.CheckAmountRoundingPrecision;
        END ELSE
            Currency.InitRoundingPrecision;

        IF Localization.Localization = 'NO' THEN
            Currency."Amount Rounding Precision" := 1;
        */



        // Iterate and update new diem details 
        /*PerDiemDetailUpdate.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
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
                PerDiemCalculation.SetRange("To DateTime", CreateDateTime(PerDiemDetail.Date, 000000T), CreateDateTime(PerDiemDetailUpdate.Date, 235959T));
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
            */
        exit(true);
    end;

    internal procedure GetValidPerDiemRate(var PerDiemRate: Record "CEM Per Diem Rate v.2"; var PerDiemSubRate: Record "CEM Per Diem Rate Details v.2"; var PerDiemDetail: Record "CEM Per Diem Detail"; PerDiem: Record "CEM Per Diem"; PerDiemCalc: Record "EMADV Per Diem Calculation"): Boolean
    var
    //PerDiemSubRate: Record "CEM Per Diem Rate Details v.2"
    begin
        PerDiemSubRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");
        if PerDiemCalc."Domestic Entry" then
            PerDiemSubRate.SetRange("Destination Country/Region", PerDiem."Departure Country/Region")
        else
            PerDiemSubRate.SetRange("Destination Country/Region", PerDiemCalc."Country/Region");
        //Not used at the moment PerDiemSubRate.SetRange("Accommodation Allowance Code");

        PerDiemSubRate.SetFilter("Start Date", '..%1', PerDiemDetail.Date);

        // Make sure to get only rates with minimum stay hours of trip
        PerDiemSubRate.SetFilter("Minimum Stay (hours)", '<=%1', GetTripDurationInHours(PerDiem));

        if PerDiemSubRate.FindLast() then begin
            if PerDiemRate.Get(PerDiemSubRate."Per Diem Group Code", PerDiemSubRate."Destination Country/Region", PerDiemSubRate."Accommodation Allowance Code", PerDiemSubRate."Start Date") then
                exit(true);
        end;

        /*
        PerDiemRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");
        if PerDiemCalc."Domestic Entry" then
            PerDiemRate.SetRange("Destination Country/Region", PerDiem."Departure Country/Region")
        else
            PerDiemRate.SetRange("Destination Country/Region", PerDiemCalc."Country/Region");
        PerDiemRate.SetFilter("Start Date", '..%1', PerDiemDetail.Date);

        // Make sure to get only rates with minimum stay hours of trip
        PerDiemRate.SetFilter("Minimum Stay (hours)", '<=%1', GetTripDurationInHours(PerDiem));

        // Make sure to get only rates with minimum stay hours of first & last day
        if ((PerDiemDetail.Date = DT2Date(PerDiem."Departure Date/Time")) or (PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time"))) then
            PerDiemRate.SetFilter("First/Last Day Minimum Stay", '<=%1', ConvertMsecDurationIntoHours(PerDiemCalc."Day Duration"))
        else
            PerDiemRate.SetFilter("Minimum Stay (hours)", '<=%1', ConvertMsecDurationIntoHours(PerDiemCalc."Day Duration"));
        //CustPerDiemRate.SetRange("Calculation Method", CalcMethod);
        exit(PerDiemRate.FindLast());
        */
    end;


    internal procedure GetTripDurationInHours(PerDiem: Record "CEM Per Diem"): Decimal
    begin
        exit(ConvertMsecDurationIntoHours(PerDiem."Return Date/Time" - PerDiem."Departure Date/Time"));
    end;

    internal procedure ConvertMsecDurationIntoHours(DurationInMsec: Integer): Decimal
    begin
        exit(Round((DurationInMsec) / (1000 * 60 * 60), 1, '>'));
    end;

    internal procedure GetTripReimbursementAmount(PerDiem: Record "CEM Per Diem") TripReimbursementAmount: Decimal
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemCalculation.IsEmpty() then
            exit(0);

        PerDiemCalculation.FindSet();
        repeat
            TripReimbursementAmount += PerDiemCalculation."Meal Reimb. Amount";
        until PerDiemCalculation.Next() = 0;
    end;

    internal procedure GetTripDurationInTwelth(PerDiem: Record "CEM Per Diem") TripTwelth: Integer
    var
        TripDurationInHours: Decimal;
    begin
        TripDurationInHours := GetTripDurationInHours(PerDiem);
        TripTwelth := (TripDurationInHours div 24) * 12;

        if TripDurationInHours mod 24 >= 12 then
            TripTwelth += 12
        else
            TripTwelth += (TripDurationInHours mod 24);
        exit(TripTwelth);
    end;
}
