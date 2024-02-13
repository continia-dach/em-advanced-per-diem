page 62084 "EMADV Per Diem Calc. Card"
{
    ApplicationArea = All;
    Caption = 'EMADV Per Diem Calc Card';
    PageType = Card;
    SourceTable = "CEM Per Diem";
    Editable = false;

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
                Caption = 'Calculation Details';


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
                    Visible = false;
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
        area(FactBoxes)
        {
            part(PerDiemDetails; "EMADV Calculation Detail FB")
            {
                ApplicationArea = All;
                Caption = 'Per diem details';
                Provider = "Per Diem Calc. Subpage";
                SubPageLink = "Per Diem Entry No." = field("Per Diem Entry No."), "Entry No." = field("Per Diem Det. Entry No.");

            }
            // Obsolete???
            // part(Destinations; "EMADV Per Diem Det. Dest FB")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Per diem destinations';
            //     Provider = "Per Diem Calc. Subpage";
            //     SubPageLink = "Per Diem Entry No." = field("Per Diem Entry No."), "Per Diem Detail Entry No." = field("Per Diem Det. Entry No.");
            // }

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
            action(Update)
            {
                ApplicationArea = All;
                Image = Recalculate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    UpdatePerDiemCalculation();
                    CurrPage.Update(false);
                end;
            }
            action("Per Diem Details")
            {
                ApplicationArea = All;
                Caption = 'Per Diem Details';
                Ellipsis = true;
                Image = Split;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+Ctrl+L';
                ToolTip = 'View or edit per diem details.';
                AboutTitle = 'Per Diem Details';
                AboutText = 'Detailed information about each day of the per diem and each element selected for reimbursement by the expense user.';

                trigger OnAction()
                var
                    PerDiemValidate: Codeunit "CEM Per Diem-Validate";
                begin
                    DrillDownDetails(Rec);
                    PerDiemValidate.RUN(Rec);
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action(OpenRateCard)
            {
                ApplicationArea = All;
                Image = Card;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PerDiemRate: Record "CEM Per Diem Rate v.2";
                    PerDiemCalculation: Record "EMADV Per Diem Calculation";
                begin
                    PerDiemRate.SetRange("Per Diem Group Code", Rec."Per Diem Group Code");
                    CurrPage."Per Diem Calc. Subpage".Page.GetRecord(PerDiemCalculation);
                    PerDiemRate.SetRange("Destination Country/Region", PerDiemCalculation."Country/Region");
                    PerDiemRate.SetFilter("Start Date", '..%1', DT2date(PerDiemCalculation."To DateTime"));
                    if PerDiemRate.FindLast() then
                        Page.RunModal(page::"CEM Per Diem Rate Card v.2", PerDiemRate);
                end;
            }
        }

    }
    trigger OnAfterGetCurrRecord()
    begin
        UpdatePerDiemCalculation();
    end;

    local procedure UpdatePerDiemCalculation()
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemGroup: Record "CEM Per Diem Group";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", Rec."Entry No.");
        if PerDiemDetail.FindFirst() then
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
        CurrPage.Update(false);
    end;

    internal procedure DrillDownDetails(PerDiem: Record "CEM Per Diem")
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SETRANGE("Per Diem Entry No.", PerDiem."Entry No.");
        PAGE.RUNMODAL(PAGE::"CEM Per Diem Details", PerDiemDetail);
        if PerDiemDetail.FindFirst() then begin
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
            CurrPage.Update(false);
        end;
    end;

    var
        CalculationMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        CalculateAustrianPerDiem: Boolean;
}