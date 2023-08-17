page 62081 "EMADV Cust PD Rates"
{
    ApplicationArea = All;
    Caption = 'EMADV Cust PD Rates';
    PageType = List;
    SourceTable = "EMADV Cust PerDiem Rate";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Per Diem Group Code"; Rec."Per Diem Group Code")
                {
                    ToolTip = 'Specifies the value of the Per Diem Group Code field.';
                }
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("Accommodation Allowance Code"; Rec."Accommodation Allowance Code")
                {
                    ToolTip = 'Specifies the value of the Accommodation Allowance Code field.';
                }
                field("Calculation Method"; Rec."Calculation Method")
                {
                    ToolTip = 'Specifies the value of the Calculation method field.';
                }
                field("Daily Accommodation Allowance"; Rec."Daily Accommodation Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free Accommodation Allowance field.';
                }
                field("Daily Meal Allowance"; Rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free Meal Allowance field.';
                }
                field("Breakfast deduction"; Rec."Breakfast deduction")
                {
                    ToolTip = 'Specifies the value of the Breakfast deduction field.';
                }
                field("Breakfast-Lunch Amt."; Rec."Breakfast-Lunch Amt.")
                {
                    ToolTip = 'Specifies the value of the Breakfast-Lunch Amt. field.';
                }
                field("Breakfast-Lunch-Dinner Amt."; Rec."Breakfast-Lunch-Dinner Amt.")
                {
                    ToolTip = 'Specifies the value of the Breakfast-Lunch-Dinner Amt. field.';
                }
            }
        }
    }
}
