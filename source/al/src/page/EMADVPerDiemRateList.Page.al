page 62082 "EMADV Per Diem Rate List"
{
    ApplicationArea = All;
    Caption = 'EMADV Per Diem Rate List';
    PageType = List;
    SourceTable = "CEM Per Diem Rate v.2";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Daily Accommodation Allowance"; Rec."Daily Accommodation Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free Accommodation Allowance field.';
                }
                field("Daily Drinks Allowance"; Rec."Daily Drinks Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Drinks Allowance field.';
                }
                field("Daily Entertainment Allowance"; Rec."Daily Entertainment Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Entertainment Allowance field.';
                }
                field("Daily Meal Allowance"; Rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free Meal Allowance field.';
                }
                field("Daily Transport Allowance"; Rec."Daily Transport Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Transport Allowance field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }

            }
        }
    }
}
