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
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        Currency: Record Currency;
        PerDiemRuleSetProvider: Interface "EMADV IPerDiemRuleSetProvider";
    begin
        if not EMSetup.Get() then
            exit;
        if not EMSetup."Use Custom Per Diem Engine" then
            exit;

        if PerDiemDetail."Per Diem Entry No." = 0 then
            exit
        else
            if not PerDiem.Get(PerDiemDetail."Per Diem Entry No.") then
                exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

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
        //Clear old values
        Clear(PerDiemDetail."Accommodation Allowance Amount");
        Clear(PerDiemDetail."Meal Allowance Amount");
        Clear(PerDiemDetail."Transport Allowance Amount");
        Clear(PerDiemDetail."Entertainment Allowance Amount");
        Clear(PerDiemDetail."Drinks Allowance Amount");

        Clear(PerDiemDetail."Taxable Acc. Allowance Amount");
        Clear(PerDiemDetail."Taxable Meal Allowance Amount");
        Clear(PerDiemDetail."Taxable Amount");
        Clear(PerDiemDetail."Taxable Amount (LCY)");
        // <<< Copied from Standard

        PerDiemRuleSetProvider := PerDiemGroup."Calculation rule set";
        PerDiemRuleSetProvider.CalcPerDiemRate(PerDiem, PerDiemDetail);

        PerDiemDetail.Amount := ROUND(PerDiemDetail."Accommodation Allowance Amount" + PerDiemDetail."Meal Allowance Amount" + PerDiemDetail."Transport Allowance Amount" +
              PerDiemDetail."Entertainment Allowance Amount" + PerDiemDetail."Drinks Allowance Amount", Currency."Amount Rounding Precision");
        PerDiemDetail."Amount (LCY)" := PerDiemDetail.Amount; // TODO: Set up LCY calculation
        PerDiemDetail.Modify();

        exit(true);
    end;

    internal procedure GetValidCustPerDiemRate(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate"; var PerDiemDetail: Record "CEM Per Diem Detail"; PerDiem: Record "CEM Per Diem"; CalcMethod: Enum "EMADV Per Diem Calc. Method"): Boolean
    var

    begin
        CustPerDiemRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");
        CustPerDiemRate.SetRange("Destination Country/Region", PerDiem."Destination Country/Region");
        CustPerDiemRate.SetFilter("Start Date", '..%1', PerDiemDetail.Date);
        //CustPerDiemRate.SetRange("Accommodation Allowance Code", PerDiem.);
        CustPerDiemRate.SetRange("Calculation Method", CalcMethod);
        //CustPerDiemRate.SetRange("From Hour", CustPerDiemRate."From Hour");
        exit(CustPerDiemRate.FindLast());
    end;

    internal procedure GetTripDurationInHours(PerDiem: Record "CEM Per Diem"): Text
    begin
        exit(Format(Round((PerDiem."Return Date/Time" - PerDiem."Departure Date/Time") / (1000 * 60 * 60), 1, '>')));
    end;

    internal procedure GetTripDurationInTwelth(PerDiem: Record "CEM Per Diem"): Text
    var
        TripHours: Integer;
        TripFullyDays: Integer;
        TripFullDayRest: Integer;
        TripFullDayRestTwelth: Integer;
    begin
        //exit(Format(
        TripHours := Round((PerDiem."Return Date/Time" - PerDiem."Departure Date/Time") / (1000 * 60 * 60), 1, '>');
        TripFullyDays := TripHours div 24;
        TripFullDayRest := TripHours mod 24;
        if (TripFullDayRest >= 11) then
            TripFullDayRestTwelth := 12
        else
            TripFullDayRestTwelth := TripFullDayRest;

        exit(format(TripFullyDays * 12 + TripFullDayRestTwelth));
    end;
}
