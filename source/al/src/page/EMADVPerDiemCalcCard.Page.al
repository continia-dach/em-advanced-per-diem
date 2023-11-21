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
                Caption = 'Travel details';

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
                field("Destination Country/Region"; Rec."Destination Country/Region")
                {
                    ToolTip = 'Specifies the destination country or region.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the per diem.';
                    Visible = false;
                }
            }

            part("Per Diem Calc. Subpage"; "EMADV Per Diem Calc. List")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Per Diem Entry No." = field("Entry No.");
            }
            group(Calculation)
            {
                Caption = 'Calculation';


                field(TripDurationInHours; CalculationMgt.GetTripDurationInHours(Rec))
                {
                    ToolTip = 'Specifies the duration of the trip';
                }
                field(TripDurationInTwelth; CalculationMgt.GetTripDurationInTwelth(Rec))
                {
                    ToolTip = 'Specifies the duration in Austrian twelth';
                }
                field(TripMealReimbursementAmount; CalculationMgt.GetTripReimbursementAmount(Rec))
                {
                    ToolTip = 'Specifies the reimbursement amount of the current per diem';
                }
                field("EM Standard Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount.';
                }
                field("EM Standard Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in local currency calculated based on the mileage rates.';
                }

            }
        }

    }
    actions
    {
        area(Navigation)
        {
            action(PerDiemGroup)
            {
                ApplicationArea = All;
                RunObject = Page "CEM Per Diem Group Card";
                RunPageLink = Code = field("Per Diem Group Code");
                RunPageMode = View;
                Image = Card;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
            }
        }

    }
    trigger OnAfterGetCurrRecord()
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemGroup: Record "CEM Per Diem Group";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", Rec."Entry No.");
        if PerDiemDetail.FindFirst() then
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
        //if PerDiemGroup.Get(Rec."Per Diem Group Code") then
        //    CalculateAustrianPerDiem := (PerDiemGroup."Calculation rule set" in [PerDiemGroup."Calculation rule set"::Austria24h, PerDiemGroup."Calculation rule set"::AustriaByDay])
    end;

    var
        CalculationMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        CalculateAustrianPerDiem: Boolean;
}