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
                field("Per Diem Group Code"; Rec."Per Diem Group Code")
                {
                    ToolTip = 'Specifies the value of the Per Diem Group Code field.';
                    Visible = false;
                }
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
                    BlankZero = true;
                }
                field("Daily Drinks Allowance"; Rec."Daily Drinks Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Drinks Allowance field.';
                    BlankZero = true;
                }
                field("Daily Entertainment Allowance"; Rec."Daily Entertainment Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Entertainment Allowance field.';
                    BlankZero = true;
                }
                field("Daily Meal Allowance"; Rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free Meal Allowance field.';
                    BlankZero = true;
                }
                field("Daily Transport Allowance"; Rec."Daily Transport Allowance")
                {
                    ToolTip = 'Specifies the value of the Daily Transport Allowance field.';
                    BlankZero = true;
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Meal Value Method"; Rec."Meal Value Method")
                {
                    ToolTip = 'Specifies the value of the Meal Value Method field.';
                    Visible = false;
                }
                field("Breakfast Value"; Rec."Breakfast Value")
                {
                    ToolTip = 'Specifies the value of the Breakfast field.';
                    BlankZero = true;
                    Visible = false;
                }
                field("Lunch Value"; Rec."Lunch Value")
                {
                    ToolTip = 'Specifies the value of the Lunch field.';
                    BlankZero = true;
                    Visible = false;
                }
                field("Dinner Value"; Rec."Dinner Value")
                {
                    ToolTip = 'Specifies the value of the Dinner field.';
                    BlankZero = true;
                    Visible = false;
                }
                field("First/Last Day Calc. Method"; Rec."First/Last Day Calc. Method")
                {
                    ToolTip = 'Specifies the value of the First/Last day calculation method field.';
                    Visible = false;
                }
                field("First/Last Day Meal Allowance"; Rec."First/Last Day Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the Tax-Free First/Last Day Meal Allowance field.';
                    BlankZero = true;
                    Visible = false;
                }
                field("First/Last Day Minimum Stay"; Rec."First/Last Day Minimum Stay")
                {
                    ToolTip = 'Specifies the value of the First/Last Day Minimum Stay field.';
                    BlankZero = true;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(RateCard)
            {
                ApplicationArea = All;
                Caption = 'Rate Card';
                RunObject = page "CEM Per Diem Rate Card v.2";
                RunPageOnRec = true;
                RunPageMode = Edit;

                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Rate Card action.';
            }
        }
    }
}
