pageextension 62081 "EMADV Per Diem Rate Details" extends "CEM Per Diem Details"
{
    actions
    {

        addfirst(Processing)
        {
            group(Setup)
            {
                Caption = 'EM ADV';
                action(Update)
                {
                    ApplicationArea = All;
                    Caption = 'Update details';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Update current line';

                    trigger OnAction()
                    var
                        CustPerDiemCalMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
                    begin
                        CurrPage.Update(true);
                        CustPerDiemCalMgt.CalcCustPerDiemRate(Rec);
                    end;
                }
            }
        }
    }
}