pageextension 62085 "EMADV Per Diem Rate Card Ext." extends "CEM Per Diem Rate Card v.2"
{
    layout
    {
        modify("Meal rate details")
        {
            Visible = not AustrianPerDiemEnabled;
        }
        addbefore("Additional allowances")
        {
            group(ATMealRateDetails)
            {
                Caption = 'Meals';
                Visible = AustrianPerDiemEnabled;
                field("DailyMealAllowance"; Rec."Daily Meal Allowance")
                {
                    ApplicationArea = All;
                    Caption = 'Tax-Free Allowance';
                    ToolTip = 'Specifies the daily allowance amount for the meal.';

                    // trigger OnValidate()
                    // begin
                    //     SplitDailyMealAllowance(Rec);
                    // end;
                }
                field("TaxableDailyMealAllowance"; Rec."Taxable Daily Meal Allowance")
                {
                    ApplicationArea = All;
                    Caption = 'Taxable Allowance';
                    ToolTip = 'Specifies the daily taxable allowance amount for the meal.';
                    Visible = TaxableFieldsVisible;
                }
            }
            part(PerDiemRateDetailsAdv; "CEM Per Diem Rate Detail v.2")
            {
                ApplicationArea = All;
                SubPageLink = "Per Diem Group Code" = FIELD("Per Diem Group Code"),
                              "Destination Country/Region" = FIELD("Destination Country/Region"),
                              "Accommodation Allowance Code" = FIELD("Accommodation Allowance Code"),
                              "Start Date" = FIELD("Start Date");
                Visible = AustrianPerDiemEnabled;
            }
        }
    }
    actions
    {
        addfirst(Navigation)
        {
            action(MealDeductions)
            {

                ApplicationArea = All;
                Caption = 'Rate meal deductions';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = LineDiscount;

                RunObject = page "EMADV Meal Deduction List";
                RunPageLink = "Per Diem Group Code" = field("Per Diem Group Code"), "Destination Country/Region" = field("Destination Country/Region"),
                              "Accommodation Allowance Code" = field("Accommodation Allowance Code"), "Start Date" = field("Start Date");
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiemGroup: Record "CEM Per Diem Group";
    begin
        if not EMSetup.Get() then
            exit;

        if not PerDiemGroup.Get(rec."Per Diem Group Code") then
            exit;
        AdvancedPerDiemEnabled := EMSetup."Use Custom Per Diem Engine";
        AustrianPerDiemEnabled := (PerDiemGroup."Calculation rule set" in [PerDiemGroup."Calculation rule set"::Austria24h, PerDiemGroup."Calculation rule set"::AustriaByDay]);
        TaxableFieldsVisible := EMSetup."Enable taxable Per Diem";
    end;

    // local procedure SplitDailyMealAllowance(Rec: Record "CEM Per Diem Rate v.2")
    // var
    //     PerDiemGroup: Record "CEM Per Diem Group";
    //     PerDiemRateDetails: Record "CEM Per Diem Rate Details v.2";
    //     ConfirmMgt: Codeunit "Confirm Management";
    //     i: Integer;
    // begin
    //     if not AustrianPerDiemEnabled then
    //         exit;

    //     if not PerDiemGroup.Get(Rec."Per Diem Group Code") then
    //         exit;

    //     if not PerDiemGroup."Auto-split AT per diem meal" then
    //         exit;

    //     if Rec."Daily Meal Allowance" = 0 then begin
    //         PerDiemRateDetails.SetRange("Per Diem Group Code", Rec."Per Diem Group Code");
    //         PerDiemRateDetails.SetRange("Destination Country/Region", Rec."Destination Country/Region");
    //         PerDiemRateDetails.SetRange("Accommodation Allowance Code", Rec."Accommodation Allowance Code");
    //         PerDiemRateDetails.SetRange("Start Date", Rec."Start Date");
    //         if PerDiemRateDetails.IsEmpty then
    //             exit;
    //         if ConfirmMgt.GetResponse('Do you want delete all per diem rate details?', true) then
    //             PerDiemRateDetails.DeleteAll(true);
    //     end else begin
    //         for i := 0 to 11 do begin
    //             Clear(PerDiemRateDetails);
    //             PerDiemRateDetails.Validate("Per Diem Group Code", Rec."Per Diem Group Code");
    //             PerDiemRateDetails.Validate("Destination Country/Region", Rec."Destination Country/Region");
    //             PerDiemRateDetails.Validate("Accommodation Allowance Code", Rec."Accommodation Allowance Code");
    //             PerDiemRateDetails.Validate("Start Date", Rec."Start Date");
    //             PerDiemRateDetails.Validate("Minimum Stay (hours)", i);
    //             PerDiemRateDetails.Validate("Meal Allowance", Rec."Daily Meal Allowance" / 12 * (i + 1));
    //             if not PerDiemRateDetails.Insert(true) then
    //                 exit;
    //         end;
    //     end;
    // end;

    var
        AdvancedPerDiemEnabled: Boolean;
        AustrianPerDiemEnabled: Boolean;
        TaxableFieldsVisible: Boolean;
}
