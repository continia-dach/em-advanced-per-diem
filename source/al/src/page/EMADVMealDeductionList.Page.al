page 62081 "EMADV Meal Deduction List"
{
    ApplicationArea = All;
    Caption = 'Meal deduction';
    PageType = ListPart;
    SourceTable = "EMADV Meal Deduction";
    UsageCategory = None;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Per Diem Group Code"; Rec."Per Diem Group Code")
                {
                    ToolTip = 'Specifies the value of the Per Diem Group Code field.';
                    Visible = false;
                }
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                    Visible = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.';
                    Visible = false;
                }
                field("Accommodation Allowance Code"; Rec."Accommodation Allowance Code")
                {
                    ToolTip = 'Specifies the value of the Accommodation Allowance Code field.';
                    Visible = false;
                }
                field("Deduction Type"; Rec."Deduction Type")
                {
                    ToolTip = 'Specifies the value of the Meal deduction type field.';
                }
                field("Deduction Method"; Rec."Deduction Method")
                {
                    ToolTip = 'Specifies if the defined value will be deducted as amount or calculated percentage';
                }
                field("Breakfast Deduction"; Rec."Breakfast Deduction")
                {
                    ToolTip = 'Specifies the value of the Breakfast deduction field.';
                }
                field("Breakfast-Lunch Deduction"; Rec."Breakfast-Lunch Deduction")
                {
                    ToolTip = 'Specifies the value of the Breakfast & Lunch deduction field.';
                }
                field("Breakfast-Dinner Deduction"; Rec."Breakfast-Dinner Deduction")
                {
                    ToolTip = 'Specifies the value of the Breakfast & Dinner deduction field.';
                }
                field("All meal Deduction"; Rec."All meal Deduction")
                {
                    ToolTip = 'Specifies the value of the All meal deduction field.';
                }
                field("Lunch Deduction"; Rec."Lunch Deduction")
                {
                    ToolTip = 'Specifies the value of the Lunch deduction field.';
                }
                field("Lunch-Dinner Deduction"; Rec."Lunch-Dinner Deduction")
                {
                    ToolTip = 'Specifies the value of the Lunch & Dinner deduction field.';
                }
                field("Dinner Deduction"; Rec."Dinner Deduction")
                {
                    ToolTip = 'Specifies the value of the Dinner deduction field.';
                }
            }
        }
    }
}
