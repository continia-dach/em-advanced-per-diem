page 62081 "EMADV Cust. PD Rate Details"
{
    ApplicationArea = All;
    Caption = 'Custom Per Diem Rate Details';
    PageType = List;
    SourceTable = "EMADV Cust PerDiem Rate Detail";
    UsageCategory = Lists;
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Calculation Method"; Rec."Calculation Method")
                {
                    ToolTip = 'Specifies the value of the Calculation method field.';
                }
                field("Deduction Amount"; Rec."Deduction Amount")
                {
                    ToolTip = 'Specifies the value of the Deduction Amount field.';
                }
                field("Deduction Description"; Rec."Deduction Description")
                {
                    ToolTip = 'Specifies the value of the Deduction Description field.';
                }
                field("Deduction Type"; Rec."Deduction Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Deduction Type field.';
                }
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                }
                field("Per Diem Group Code"; Rec."Per Diem Group Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Per Diem Group Code field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("Accommodation Allowance Code"; Rec."Accommodation Allowance Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Accommodation Allowance Code field.';
                }
            }
        }
    }
}
