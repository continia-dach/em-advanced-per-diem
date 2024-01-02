page 62085 "EMADV Per Diem Calc. List"
{
    ApplicationArea = All;
    Caption = 'Per Diem calculation details';
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
                    Visible = false;
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Name field.';
                }
                field("Duration Integer"; Rec."Day Duration")
                {
                    ToolTip = 'Specifies the value of the Duration field.';
                }

                field("Meal Allowance"; rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the meal allowance';
                }
                field("Meal Allowance Deductions"; Rec."Meal Allowance Deductions")
                {
                    ToolTip = 'Specifies the amount that will be deducted from the meal allowance';
                }
                field("Meal Reimb. Amount"; Rec."Meal Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed meal amount';
                }
                field("Accommodation Reimb. Amount"; Rec."Accommodation Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed accommodation amount';
                }
                field("Accommodation Allowance"; rec."Daily Accommodation Allowance")
                {
                    ToolTip = 'Specifies the value of the accommodation Allowance.';
                    Visible = false;
                }
                field("AT Per Diem Reimbursed Twelfth"; Rec."AT Per Diem Reimbursed Twelfth")
                {
                    ToolTip = 'Specifies the number of twelth used to calculate the reimbursed amount.';
                    Visible = CalculateAustrianPerDiem;
                }
                field("AT Per Diem Twelfth"; Rec."AT Per Diem Twelfth")
                {
                    ToolTip = 'Specifies the value of the AT Per Diem Twelfth field.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PerDiem: Record "CEM Per Diem";
        PerDiemGroup: Record "CEM Per Diem Group";
    begin
        if PerDiem.Get(Rec."Per Diem Entry No.") then
            if PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
                CalculateAustrianPerDiem := (PerDiemGroup."Calculation rule set" in [PerDiemGroup."Calculation rule set"::Austria24h, PerDiemGroup."Calculation rule set"::AustriaByDay])
    end;

    var
        CalculateAustrianPerDiem: Boolean;
}
