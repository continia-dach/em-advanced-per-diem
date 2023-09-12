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
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("From Time"; Rec."From Time")
                {
                    ToolTip = 'Specifies the value of the From Time field.';
                }
                field("To Time"; Rec."To Time")
                {
                    ToolTip = 'Specifies the value of the To Time field.';
                }
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Name field.';
                }
                field("Duration Integer"; Rec."Day Duration")
                {
                    ToolTip = 'Specifies the value of the Duration Integer field.';
                }
                field("Per Diem Det. Entry No."; Rec."Per Diem Det. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Detail Entry No. field.';
                }
            }
        }
    }
}
