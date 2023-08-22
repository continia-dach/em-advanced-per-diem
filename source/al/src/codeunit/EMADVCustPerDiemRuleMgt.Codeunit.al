codeunit 62080 "EMADV Cust. Per Diem Rule Mgt."
{
    internal procedure SetupAustrianRuleDetailsForCustPerDiemRate(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate"): Boolean
    var
        CustPerDiemRateFirstDay: Record "EMADV Cust PerDiem Rate";
        CustPerDiemRateLastDay: Record "EMADV Cust PerDiem Rate";
        CurrFromHour: Integer;
    begin
        CustPerDiemRate.TestField(CustPerDiemRate."Daily Meal Allowance");
        CustPerDiemRate.TestField("Calculation Method", CustPerDiemRate."Calculation Method"::FullDay);

        SetupAustrianRuleDetailsForCustPerDiemRateDetails(CustPerDiemRate);

        // Create First Day Record
        // 1. Delete all First Day records
        CustPerDiemRateFirstDay.SetRange("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateFirstDay.SetRange("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateFirstDay.SetRange("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateFirstDay.SetRange("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateFirstDay.SetRange("Calculation Method", CustPerDiemRateFirstDay."Calculation Method"::FirstDay);
        if not CustPerDiemRateFirstDay.IsEmpty then
            CustPerDiemRateFirstDay.DeleteAll(true);

        for CurrFromHour := 3 to 11 do begin
            Clear(CustPerDiemRateFirstDay);
            CustPerDiemRateFirstDay.TransferFields(CustPerDiemRate);
            CustPerDiemRateFirstDay.Validate("Calculation Method", CustPerDiemRateFirstDay."Calculation Method"::FirstDay);
            CustPerDiemRateFirstDay.Validate("From Hour", CurrFromHour);
            CustPerDiemRateFirstDay.Validate("Daily Accommodation Allowance", 0);
            CustPerDiemRateFirstDay.Validate("Daily Meal Allowance", CustPerDiemRate."Daily Meal Allowance" / 12 * (CurrFromHour + 1));
            CustPerDiemRateFirstDay.Insert(true);
        end;

    end;

    internal procedure SetupGermanRuleDetailsForCustPerDiemRate(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate"): Boolean
    var
        CustPerDiemRateFirstDay: Record "EMADV Cust PerDiem Rate";
        CustPerDiemRateLastDay: Record "EMADV Cust PerDiem Rate";
    begin
        CustPerDiemRate.TestField(CustPerDiemRate."Daily Meal Allowance");
        CustPerDiemRate.TestField("Calculation Method", CustPerDiemRate."Calculation Method"::FullDay);

        SetupGermanRuleDetailsForCustPerDiemRateDetails(CustPerDiemRate);


        // Create First Day Record
        CustPerDiemRateFirstDay.SetRange("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateFirstDay.SetRange("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateFirstDay.SetRange("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateFirstDay.SetRange("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateFirstDay.SetRange("Calculation Method", CustPerDiemRateFirstDay."Calculation Method"::FirstDay);
        if not CustPerDiemRateFirstDay.IsEmpty then
            CustPerDiemRateFirstDay.DeleteAll(true);

        Clear(CustPerDiemRateFirstDay);
        CustPerDiemRateFirstDay.TransferFields(CustPerDiemRate);
        CustPerDiemRateFirstDay.Validate("Calculation Method", CustPerDiemRateFirstDay."Calculation Method"::FirstDay);
        CustPerDiemRateFirstDay.Validate("From Hour", 8);
        CustPerDiemRateFirstDay.Validate("Daily Accommodation Allowance", 0);
        CustPerDiemRateFirstDay.Insert(true);
        SetupGermanRuleDetailsForCustPerDiemRateDetails(CustPerDiemRateFirstDay);
        CustPerDiemRateFirstDay.Validate("Daily Meal Allowance", CustPerDiemRate."Daily Meal Allowance" / 2);
        CustPerDiemRateFirstDay.Modify(true);

        // Create Last Day Record
        if CustPerDiemRateLastDay.Get(CustPerDiemRate."Per Diem Group Code", CustPerDiemRate."Destination Country/Region", CustPerDiemRate."Start Date",
                                        CustPerDiemRate."Accommodation Allowance Code", CustPerDiemRateLastDay."Calculation Method"::LastDay, 0) then
            CustPerDiemRateLastDay.Delete();

        Clear(CustPerDiemRateFirstDay);
        CustPerDiemRateLastDay.TransferFields(CustPerDiemRate);
        CustPerDiemRateLastDay.Validate("Calculation Method", CustPerDiemRateLastDay."Calculation Method"::LastDay);
        CustPerDiemRateLastDay.Validate("From Hour", 0);
        CustPerDiemRateLastDay.Insert(true);
        SetupGermanRuleDetailsForCustPerDiemRateDetails(CustPerDiemRateLastDay);
        CustPerDiemRateLastDay.Validate("Daily Meal Allowance", CustPerDiemRate."Daily Meal Allowance" / 2);
        CustPerDiemRateLastDay.Modify(true);
    end;

    local procedure SetupGermanRuleDetailsForCustPerDiemRateDetails(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate")
    var
        CustPerDiemRateDetail: Record "EMADV Cust PerDiem Rate Detail";
    begin
        // Delete existing records
        CustPerDiemRateDetail.SetRange("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateDetail.SetRange("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateDetail.SetRange("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateDetail.SetRange("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateDetail.SetRange("Calculation Method", CustPerDiemRate."Calculation Method");
        CustPerDiemRateDetail.SetRange("From Hour", CustPerDiemRate."From Hour");
        CustPerDiemRateDetail.DeleteAll(true);

        // Init per diem detail rate record
        Clear(CustPerDiemRateDetail);
        CustPerDiemRateDetail.Validate("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateDetail.Validate("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateDetail.Validate("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateDetail.Validate("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateDetail.Validate("Calculation Method", CustPerDiemRate."Calculation Method");
        CustPerDiemRateDetail.Validate("From Hour", CustPerDiemRate."From Hour");

        // Breakfast only
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Breakfast);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        CustPerDiemRateDetail.Insert(true);

        // Breakfast+Lunch
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunch);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunch);
        CustPerDiemRateDetail.Validate("Line No.", 20000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        // Breakfast+Lunch+Dinner
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 20000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 30000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        // Lunch
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Lunch);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        // Lunch+Dinner
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::LunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::LunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 20000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 40%');
        CustPerDiemRateDetail.Insert(true);

        // Dinner
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Dinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.4);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 40%');
        CustPerDiemRateDetail.Insert(true);
    end;

    local procedure SetupAustrianRuleDetailsForCustPerDiemRateDetails(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate")
    var
        CustPerDiemRateDetail: Record "EMADV Cust PerDiem Rate Detail";
    begin
        // Delete existing records
        CustPerDiemRateDetail.SetRange("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateDetail.SetRange("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateDetail.SetRange("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateDetail.SetRange("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateDetail.SetRange("Calculation Method", CustPerDiemRate."Calculation Method");
        CustPerDiemRateDetail.SetRange("From Hour", CustPerDiemRate."From Hour");
        CustPerDiemRateDetail.DeleteAll(true);

        // Init per diem detail rate record
        Clear(CustPerDiemRateDetail);
        CustPerDiemRateDetail.Validate("Per Diem Group Code", CustPerDiemRate."Per Diem Group Code");
        CustPerDiemRateDetail.Validate("Destination Country/Region", CustPerDiemRate."Destination Country/Region");
        CustPerDiemRateDetail.Validate("Start Date", CustPerDiemRate."Start Date");
        CustPerDiemRateDetail.Validate("Accommodation Allowance Code", CustPerDiemRate."Accommodation Allowance Code");
        CustPerDiemRateDetail.Validate("Calculation Method", CustPerDiemRate."Calculation Method");
        CustPerDiemRateDetail.Validate("From Hour", CustPerDiemRate."From Hour");

        // // Breakfast only
        // CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Breakfast);
        // CustPerDiemRateDetail.Validate("Line No.", 10000);
        // CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        // CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        // CustPerDiemRateDetail.Insert(true);

        // Breakfast+Lunch
        // CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunch);
        // CustPerDiemRateDetail.Validate("Line No.", 10000);
        // CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        // CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        // CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunch);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        // Breakfast+Lunch+Dinner
        // CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        // CustPerDiemRateDetail.Validate("Line No.", 10000);
        // CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.2);
        // CustPerDiemRateDetail.Validate("Deduction Description", 'Breakfast Deduction 20%');
        // CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::BreakfastLunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 20000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        // Lunch
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Lunch);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        // Lunch+Dinner
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::LunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Lunch Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::LunchDinner);
        CustPerDiemRateDetail.Validate("Line No.", 20000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 50%');
        CustPerDiemRateDetail.Insert(true);

        // Dinner
        CustPerDiemRateDetail.Validate("Deduction Type", CustPerDiemRateDetail."Deduction Type"::Dinner);
        CustPerDiemRateDetail.Validate("Line No.", 10000);
        CustPerDiemRateDetail.Validate("Deduction Amount", CustPerDiemRate."Daily Meal Allowance" * 0.5);
        CustPerDiemRateDetail.Validate("Deduction Description", 'Dinner Deduction 50%');
        CustPerDiemRateDetail.Insert(true);
    end;
}
