pageextension 62081 "EMADV Per Diem Rate Details" extends "CEM Per Diem Details"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("Per Diem Dest. Details"; "EMADV Per Diem Det. Dest FB")
            {
                ApplicationArea = All;
                Visible = MultiDestinationsEnabled;
                Caption = 'Per Diem Destinations';
                SubPageLink = "Per Diem Entry No." = field("Per Diem Entry No."),
                              "Per Diem Detail Entry No." = field("Entry No.");
            }
        }
    }
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
    trigger OnOpenPage()
    var
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        MultiDestinationsEnabled := EMSetup."Enable Per Diem Destinations";
    end;

    var
        MultiDestinationsEnabled: Boolean;
}