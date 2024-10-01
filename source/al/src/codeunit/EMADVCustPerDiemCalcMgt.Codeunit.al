codeunit 62081 "EMADV Cust. Per Diem Calc.Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"CEM Per Diem", 'OnAfterModifyEvent', '', true, true)]
    local procedure PerDiem_OnAfterModifyEvent(var Rec: Record "CEM Per Diem"; var xRec: Record "CEM Per Diem"; RunTrigger: Boolean)
    begin
        //UpdatePerDiem(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CEM Per Diem-Validate", 'OnBeforePerDiemValidate', '', true, true)]
    local procedure PerDiemValidate_OnBeforePerDiemValidate(var Rec: Record "CEM Per Diem")
    begin
        CheckDestinationOverlap(Rec);

        UpdatePerDiem(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CEM Per Diem Calc. Engine", OnBeforeFindRateAndUpdateAmtOnDetail, '', false, false)]
    local procedure PerDiemCalcEngine_OnBeforeFindRateAndUpdateAmtOnDetail(var PerDiemDetails: Record "CEM Per Diem Detail"; var IsHandled: Boolean)
    begin
        IsHandled := CalcCustPerDiemRate(PerDiemDetails);
    end;

    internal procedure UpdatePerDiem(PerDiem: Record "CEM Per Diem")
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindFirst() then
            CalcCustPerDiemRate(PerDiem, PerDiemDetail);
    end;

    internal procedure CalcCustPerDiemRate(PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail") CalculationResult: Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemGroup: Record "CEM Per Diem Group";
        Currency: Record Currency;
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
        PerDiemDetailUpdate: Record "CEM Per Diem Detail";
        PerDiemRuleSetProvider: Interface "EMADV IPerDiemRuleSetProvider";
    begin
        if not EMSetup.Get() then
            exit;
        if not EMSetup."Use Custom Per Diem Engine" then
            exit;

        if (PerDiem."Departure Date/Time" = 0DT) or (PerDiem."Return Date/Time" = 0DT) then
            exit;

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        if PerDiemGroup."Calculation rule set" = PerDiemGroup."Calculation rule set"::Default then
            exit;

        // Recalculation and update of reimbursement amounts only on first record until we are sure, that we do it only once
        if PerDiemDetail."Entry No." <> 1 then
            exit(true);

        PerDiemRuleSetProvider := PerDiemGroup."Calculation rule set";
        CalculationResult := PerDiemRuleSetProvider.CalcPerDiemRate(PerDiem, PerDiemDetail);

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
        //exit(true);
    end;

    internal procedure CalcCustPerDiemRate(var PerDiemDetail: Record "CEM Per Diem Detail") CalculationResult: Boolean
    var
        PerDiem: Record "CEM Per Diem";
    begin
        if not PerDiem.Get(PerDiemDetail."Per Diem Entry No.") then
            exit;

        exit(CalcCustPerDiemRate(PerDiem, PerDiemDetail));
    end;

    internal procedure UpdatePerDiemDetail(var PerDiemDetail: Record "CEM Per Diem Detail") CalculationResult: Boolean
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

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        PerDiemRuleSetProvider := PerDiemGroup."Calculation rule set";
        PerDiemRuleSetProvider.UpdatePerDiemDetail(PerDiem, PerDiemDetail);
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
        PerDiemSubRate.SetFilter("Minimum Stay (hours)", '<%1', ConvertMsecDurationIntoHours(PerDiemCalc."Day Duration", 1, '>'));

        if PerDiemSubRate.FindLast() then begin
            if PerDiemRate.Get(PerDiemSubRate."Per Diem Group Code", PerDiemSubRate."Destination Country/Region", PerDiemSubRate."Accommodation Allowance Code", PerDiemSubRate."Start Date") then
                exit(true);
        end;
    end;

    internal procedure ResetPerDiemCalculation(var PerDiem: Record "CEM Per Diem")
    var
        PerDiemCalculation: Record "EMADV Per Diem Calculation";
    begin
        PerDiemCalculation.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if not PerDiemCalculation.IsEmpty then
            PerDiemCalculation.DeleteAll(true);
    end;

    internal procedure GetTripDurationInHours(PerDiem: Record "CEM Per Diem"; Precision: Decimal; Direction: Text[1]): Decimal
    begin
        exit(ConvertMsecDurationIntoHours(PerDiem."Return Date/Time" - PerDiem."Departure Date/Time", Precision, Direction));
    end;

    internal procedure GetTripDurationInHours(PerDiem: Record "CEM Per Diem"): Decimal
    begin
        exit(GetTripDurationInHours(PerDiem, 1, '>'));
    end;

    internal procedure ConvertMsecDurationIntoHours(DurationInMsec: BigInteger; Precision: Decimal; Direction: Text[1]): Decimal
    begin
        exit(Round((DurationInMsec) / (1000 * 60 * 60), Precision, Direction));
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

    ///<summary>Helper functionality to check if current Per Diem Detail entry is first day of Per Diem</summary>
    internal procedure IsFirstDay(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    begin
        exit(PerDiemDetail.Date = DT2Date(PerDiem."Departure Date/Time"));
    end;

    ///<summary>Helper functionality to check if current Per Diem Detail entry is last day of Per Diem</summary>
    internal procedure IsLastDay(var PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    begin
        exit(PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time"));
    end;

    internal procedure InsertCalc(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"; var PerDiemCalc: Record "EMADV Per Diem Calculation"; FromDateTime: DateTime; ToDateTime: DateTime; CurrCountry: Record "CEM Country/Region"; UpdateCurrCalcToDTWithNewFromDT: Boolean)
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
        PerDiemCalc.Validate("Domestic Entry", CurrCountry."Domestic Country");
        PerDiemCalc.Validate("Country/Region", CurrCountry.Code);
        PerDiemCalc.Insert(true);
    end;

    internal procedure UpdateCalcWithToDT(var PerDiemCalculation: Record "EMADV Per Diem Calculation"; ToDateTime: DateTime)
    begin
        PerDiemCalculation.Validate("To DateTime", ToDateTime);
        PerDiemCalculation.Modify(true);
    end;



    local procedure CheckDestinationOverlap(var PerDiem: Record "CEM Per Diem")
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemDetailDest: Record "CEM Per Diem Detail Dest.";
    begin
        if PerDiem."Departure Date/Time" <> 0DT then begin
            PerDiemDetailDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
            if not PerDiemDetailDest.IsEmpty then
                if PerDiemDetailDest.FindFirst() then begin
                    PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                    PerDiemDetail.SetRange("Entry No.", PerDiemDetailDest."Per Diem Detail Entry No.");
                    if PerDiemDetail.FindFirst() then
                        if (CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time") < PerDiem."Departure Date/Time") or
                           (CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time") > PerDiem."Return Date/Time")
                        then
                            Error(DepartureTimeOverlapsDestination);
                end

        end;

        if PerDiem."Return Date/Time" <> 0DT then begin
            PerDiemDetailDest.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
            if not PerDiemDetailDest.IsEmpty then
                if PerDiemDetailDest.FindLast() then begin
                    PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                    PerDiemDetail.SetRange("Entry No.", PerDiemDetailDest."Per Diem Detail Entry No.");
                    if PerDiemDetail.FindLast() then
                        if (CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time") < PerDiem."Departure Date/Time") or
                           (CreateDateTime(PerDiemDetail.Date, PerDiemDetailDest."Arrival Time") > PerDiem."Return Date/Time")
                        then
                            Error(DepartureTimeOverlapsDestination);
                end

        end;
    end;

    var
        DepartureTimeOverlapsDestination: Label 'The per diem departure time overlaps with existing per diem destinations!';
}
