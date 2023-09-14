page 62085 "EMADV Per Diem Calc. List"
{
    ApplicationArea = All;
    Caption = 'EMADV Per Diem Calc. List';
    PageType = List;
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
                }
                field("Per Diem Det. Entry No."; Rec."Per Diem Det. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Detail Entry No. field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
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
                field("AT Per Diem Twelfth"; Rec."AT Per Diem Twelfth")
                {
                    ToolTip = 'Specifies the value of the AT Per Diem Twelfth field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetFilter("Per Diem Entry No.", Rec.GetFilter("Per Diem Entry No."));
        if PerDiemDetail.FindFirst() then
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
    end;
}
