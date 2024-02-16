page 62087 "EMADV Per Diem FB"
{
    ApplicationArea = All;
    Caption = 'Per Diem Summary';
    PageType = CardPart;
    SourceTable = "CEM Per Diem";

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;

                field(Description; Rec.Description)
                {
                    ToolTip = 'Shows the per diem description';
                }

                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in local currency calculated based on the mileage rates.';
                }
                field("Departure Date/Time"; Rec."Departure Date/Time")
                {
                    ToolTip = 'Specifies the date and time of the departure.';
                }
                field("Departure Country/Region"; Rec."Departure Country/Region")
                {
                    ToolTip = 'Specifies the departure country or region.';
                    Visible = false;
                }
                field("Return Date/Time"; Rec."Return Date/Time")
                {
                    ToolTip = 'Specifies the date and time of the return.';
                }
            }
        }
    }
}