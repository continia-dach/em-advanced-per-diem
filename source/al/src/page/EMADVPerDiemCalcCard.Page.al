page 62084 "EMADV Per Diem Calc. Card"
{
    ApplicationArea = All;
    Caption = 'EMADV Per Diem Calc Card';
    PageType = Card;
    SourceTable = "CEM Per Diem";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Departure Date/Time"; Rec."Departure Date/Time")
                {
                    ToolTip = 'Specifies the date and time of the departure.';
                }
                field("Departure Country/Region"; Rec."Departure Country/Region")
                {
                    ToolTip = 'Specifies the departure country or region.';
                }
                field("Return Date/Time"; Rec."Return Date/Time")
                {
                    ToolTip = 'Specifies the date and time of the return.';
                }
                field(TripDurationInHours; CalculationMgt.GetTripDurationInHours(Rec))
                {
                    ToolTip = 'Specifies the duration of the trip';
                }
                field(TripDurationInTwelth; CalculationMgt.GetTripDurationInTwelth(Rec))
                {
                    ToolTip = 'Specifies the duration of the trip';
                }
                field("Destination Country/Region";
                Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the destination country or region.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in local currency calculated based on the mileage rates.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the per diem.';
                }

            }
            part("Per Diem Calc. Subpage"; "EMADV Per Diem Calc. List")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Per Diem Entry No." = field("Entry No.");
            }
        }

    }
    trigger OnAfterGetRecord()
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", Rec."Entry No.");
        if PerDiemDetail.FindFirst() then
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
    end;

    var
        CalculationMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
}