page 62086 "EMADV Calculation Detail FB"
{
    ApplicationArea = All;
    Caption = 'Day Details';
    PageType = CardPart;
    SourceTable = "EMADV Per Diem Calculation";

    layout
    {
        area(content)
        {
            group(PerDiemDate)
            {

                ShowCaption = false;
                field(Date; PerDiemDetail.Date)
                {
                }
            }
            group(Meal)
            {
                Caption = 'Meal';

                field(Breakfast; PerDiemDetail.Breakfast)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        PerDiemDetail.Breakfast := not PerDiemDetail.Breakfast;
                        CurrPage.Update();
                    end;
                }
                field(Lunch; PerDiemDetail.Lunch)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        PerDiemDetail.Lunch := not PerDiemDetail.Lunch;
                        RecalculatePerDiem();
                        //CurrPage.Update();
                    end;
                }
                field(Dinner; PerDiemDetail.Dinner)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        PerDiemDetail.Dinner := not PerDiemDetail.Dinner;
                        RecalculatePerDiem();
                        //CurrPage.Update();
                    end;
                }
                field("Meal Allowance Amount"; PerDiemDetail."Meal Allowance Amount")
                {
                }
                field("No. of Destinations"; PerDiemDetail."No. of Destinations")
                {
                    Visible = false;
                }
            }
            group(Accommodation)
            {
                Caption = 'Accommodation';

                field("Accommodation Allowance"; PerDiemDetail."Accommodation Allowance")
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        PerDiemDetail."Accommodation Allowance" := not PerDiemDetail."Accommodation Allowance";
                        RecalculatePerDiem();

                    end;
                }
                field("Accommodation Allowance Amount"; PerDiemDetail."Accommodation Allowance Amount")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Per Diem Entry No." = 0 then
            exit;
        if (Rec."Per Diem Entry No." <> PerDiemDetail."Per Diem Entry No.") or
           (Rec."Per Diem Det. Entry No." <> PerDiemDetail."Entry No.") then begin
            PerDiemDetail.SetRange("Per Diem Entry No.", Rec."Per Diem Entry No.");
            PerDiemDetail.SetRange("Entry No.", Rec."Per Diem Det. Entry No.");
            if PerDiemDetail.IsEmpty() then
                PerDiemDetail.Init()
            else
                PerDiemDetail.FindFirst();
        end;
    end;


    local procedure RecalculatePerDiem()
    var
        PerDiem: Record "CEM Per Diem";
        CustPerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.Modify();

        if PerDiem.Get(Rec."Per Diem Entry No.") then begin
            CustPerDiemCalcMgt.UpdatePerDiem(PerDiem);
            CurrPage.Update(true);
        end;
    end;

    var
        PerDiemDetail: Record "CEM Per Diem Detail";
}
