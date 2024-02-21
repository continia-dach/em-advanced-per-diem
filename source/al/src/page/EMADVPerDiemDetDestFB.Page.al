page 62083 "EMADV Per Diem Det. Dest FB"
{
    ApplicationArea = All;
    Caption = 'Per Diem Det. Dest FB';
    PageType = ListPart;
    SourceTable = "CEM Per Diem Detail Dest.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Arrival Time"; Rec."Arrival Time")
                {
                    ToolTip = 'Specifies the destination arrival time.';
                    Width = 9;
                }
                field("Destination Country/Region"; Rec."Destination Name" + ' (' + Rec."Destination Country/Region" + ')')
                {
                    ToolTip = 'Specifies the destination country or region.';
                    Width = 20;
                }

            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Destination Name");
        DestinationNameCode := CopyStr(Rec."Destination Name" + ' (' + Rec."Destination Country/Region" + ')', 1, MaxStrLen(DestinationNameCode));
    end;

    var
        DestinationNameCode: Text[200];
}