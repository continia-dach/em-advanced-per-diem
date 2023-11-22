pageextension 62085 "EMADV Per Diem Rate Card Ext." extends "CEM Per Diem Rate Card v.2"
{
    layout
    {
        addbefore("Additional allowances")
        {
            group(AdvancedPerDiemAllowances)
            {
                Caption = 'Advanced Per Diem Meal Allowances';
                Visible = AdvancedPerDiemEnabled;
                group(FullDay)
                {
                    Caption = 'Full Day';
                    field("Full Day Meal Allowance"; Rec."Daily Meal Allowance")
                    {
                        ApplicationArea = All;
                        Caption = 'Tax-Free Meal Allowance (Full Day)';
                        ToolTip = 'Specifies the daily allowance amount for the meal.';
                    }
                    field("Taxable Full Day Meal Allowance"; Rec."Taxable Daily Meal Allowance")
                    {
                        ApplicationArea = All;
                        Caption = 'Taxable Allowance (Full Day)';
                        ToolTip = 'Specifies the daily taxable allowance amount for the meal.';
                        Visible = TaxableFieldsVisible;
                    }
                }
                group(PartDay)
                {
                    Caption = 'Part Day';
                    field("Part Day Min. Stay (hours)"; Rec."First/Last Day Minimum Stay")
                    {
                        ApplicationArea = All;
                        Caption = 'Minimum Stay (hours)';
                        ToolTip = 'Specifies the minimum number of hours for the first and the last day. No allowance will be given if the number of hours registered is less than this value.';
                    }
                    field("Part Day Meal Allowance"; Rec."First/Last Day Meal Allowance")
                    {
                        ApplicationArea = All;
                        Caption = 'Tax-Free Meal Allowance';
                        ToolTip = 'Specifies the daily allowance amount for the meal.';
                    }
                    field("Taxable Part Day Meal Allowance"; Rec."Taxable F/L Day Meal Allowance")
                    {
                        ApplicationArea = All;
                        Caption = 'Taxable Meal Allowance (Part Day)';
                        ToolTip = 'Specifies the daily taxable allowance amount for the meal.';
                        Visible = TaxableFieldsVisible;
                    }
                }
            }

            group(AdvancedPerdiemMealDeductions)
            {
                Caption = 'Advanced Per Diem Meal deductions';
                Visible = AdvancedPerDiemEnabled;
                group(FullDayDeductions)
                {
                    Caption = 'Full day meal deductions';

                    field("Full day All meal Ded."; Rec."Full day All meal Ded.")
                    {
                        ToolTip = 'Specifies the value of the All meal deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Breakfast Ded."; Rec."Full day Breakfast Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Breakfast-Lunch Ded."; Rec."Full day Breakfast-Lunch Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast & Lunch deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Breakfast-Dinner Ded."; Rec."Full day Breakfast-Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast & Dinner deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Dinner Ded."; Rec."Full day Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Dinner deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Lunch Ded."; Rec."Full day Lunch Ded.")
                    {
                        ToolTip = 'Specifies the value of the Lunch deduction (full day) field.';
                        ApplicationArea = All;
                    }
                    field("Full day Lunch-Dinner Ded."; Rec."Full day Lunch-Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Lunch & Dinner deduction (full day) field.';
                        ApplicationArea = All;
                    }
                }
                group(PartDayDeductions)
                {
                    Caption = 'Part day meal deductions';

                    field("Part day All meal Ded."; Rec."Part day All meal Ded.")
                    {
                        ToolTip = 'Specifies the value of the All meal deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Breakfast Ded."; Rec."Part day Breakfast Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Breakfast-Lunch Ded."; Rec."Part day Breakfast-Lunch Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast & Lunch deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Breakfast-Dinner Ded."; Rec."Part day Breakfast-Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Breakfast & Dinner deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Dinner Ded."; Rec."Part day Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Dinner deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Lunch Ded."; Rec."Part day Lunch Ded.")
                    {
                        ToolTip = 'Specifies the value of the Lunch deduction (part day) field.';
                        ApplicationArea = All;
                    }
                    field("Part day Lunch-Dinner Ded."; Rec."Part day Lunch-Dinner Ded.")
                    {
                        ToolTip = 'Specifies the value of the Lunch & Dinner deduction (part day) field.';
                        ApplicationArea = All;
                    }
                }
            }
        }

        modify("Meal rate details")
        {
            Visible = not AdvancedPerDiemEnabled;
        }
    }

    trigger OnAfterGetRecord()
    var
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        AdvancedPerDiemEnabled := EMSetup."Use Custom Per Diem Engine";
        TaxableFieldsVisible := EMSetup."Enable taxable Per Diem";
    end;

    var
        AdvancedPerDiemEnabled: Boolean;
        TaxableFieldsVisible: Boolean;
}
