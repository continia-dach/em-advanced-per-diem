page 62085 "EMADV Per Diem Calc. List"
{
    ApplicationArea = All;
    Caption = 'EMADV Per Diem Calc. List';
    PageType = CardPart;
    SourceTable = "EMADV Per Diem Calculation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Per Diem Entry No."; Rec."Per Diem Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Entry No. field.';
                    Visible = false;
                }
                field("Per Diem Det. Entry No."; Rec."Per Diem Det. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Detail Entry No. field.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field("From Time"; Rec."From DateTime")
                {
                    ToolTip = 'Specifies the value of the From Time field.';
                }
                field("To Time"; Rec."To DateTime")
                {
                    ToolTip = 'Specifies the value of the To Time field.';
                }
                field("Destination Country/Region"; Rec."Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Name field.';
                }
                field("Duration Integer"; Rec."Day Duration")
                {
                    ToolTip = 'Specifies the value of the Duration field.';
                }
                field("Meal Reimb. Amount"; Rec."Meal Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed meal amount';
                }
                field("Meal Allowance"; rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the meal allowance';
                }
                field("Accommodation Reimb. Amount"; Rec."Accommodation Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed accommodation amount';
                }
                field("Accommodation Allowance"; rec."Daily Accommodation Allowance")
                {
                    ToolTip = 'Specifies the value of the accommodation Allowance.';
                }
                field("AT Per Diem Reimbursed Twelfth"; Rec."AT Per Diem Reimbursed Twelfth")
                {
                    ToolTip = 'Specifies the number of twelth used to calculate the reimbursed amount.';
                }
                field("AT Per Diem Twelfth"; Rec."AT Per Diem Twelfth")
                {
                    ToolTip = 'Specifies the value of the AT Per Diem Twelfth field.';
                }
            }
        }
    }
}
