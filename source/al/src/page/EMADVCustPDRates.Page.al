page 62080 "EMADV Cust PD Rates"
{
    ApplicationArea = All;
    Caption = 'Custom Per Diem Rates';
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
                field("From Hour"; Rec."From Hour")
                {
                    ToolTip = 'Specifies the value of the from-hour field.';
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
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
                field("Breakfast-Lunch Ded."; Rec."Breakfast-Lunch Ded.")
                {
                    ToolTip = 'Specifies the value of the Breakfast-Lunch deduction field.';
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
                field("Breakfast-Lunch-Dinner Ded."; Rec."Breakfast-Lunch-Dinner Ded.")
                {
                    ToolTip = 'Specifies the value of the Breakfast-Lunch-Dinner deduction field.';
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
                field("Lunch Ded."; Rec."Lunch Ded.")
                {
                    ToolTip = 'Specifies the value of the Lunch deduction field.';
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
                field("Lunch-Dinner Ded."; Rec."Lunch-Dinner Ded.")
                {
                    ToolTip = 'Specifies the value of the Lunch-Dinner deduction field.';
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
                field("Dinner Ded."; Rec."Dinner Ded.")
                {
                    ToolTip = 'Specifies the value of the Dinner deduction field.';
                    DrillDown = true;
                    DrillDownPageId = "EMADV Cust. PD Rate Details";
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Setup)
            {
                Caption = 'E&xpense';
                action(SplitByGermanRules)
                {
                    ApplicationArea = All;
                    Caption = 'Apply German rules';
                    Image = Split;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Apply German rules to current line';

                    trigger OnAction()
                    var
                        CustPerDiemRuleMgt: Codeunit "EMADV Cust. Per Diem Rule Mgt.";
                    begin
                        CustPerDiemRuleMgt.SetupGermanRuleDetailsForCustPerDiemRate(Rec);
                    end;
                }
                action(SetupAustrianRules)
                {
                    ApplicationArea = All;
                    Caption = 'Apply Austrian rules';
                    Image = Split;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Apply Austrian rules to current line';

                    trigger OnAction()
                    var
                        CustPerDiemRuleMgt: Codeunit "EMADV Cust. Per Diem Rule Mgt.";
                    begin
                        CustPerDiemRuleMgt.SetupAustrianRuleDetailsForCustPerDiemRate(Rec);
                    end;
                }
            }
        }
    }
}