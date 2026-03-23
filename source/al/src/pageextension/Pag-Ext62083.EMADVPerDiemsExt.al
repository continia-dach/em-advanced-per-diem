pageextension 62083 "EMADV Per Diems Ext." extends "CEM Per Diems"
{
    actions
    {
        addafter(Dimensions)
        {
            action(ShowCalculationList)
            {
                ApplicationArea = All;
                Caption = 'Show Calculation';
                RunObject = page "EMADV Per Diem Calc. List";
                RunPageLink = "Per Diem Entry No." = field("Entry No.");
                RunPageMode = View;
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }

            action("Update Per Diem Calculations")
            {
                ApplicationArea = All;
                Caption = 'Update Per Diem Calculations';
                Image = Refresh;
                ToolTip = 'Update incomplete Per Diem calculations where allowance and deduction amounts are zero but have positive amounts to calculate.';

                trigger OnAction()
                var
                    PerDiemDetailUpdate: report "EMADV Update Per Diem Calc.";
                    PerDiem: Record "CEM Per Diem";
                begin
                    PerDiem.SetRange("Entry No.", Rec."Entry No.");
                    PerDiemDetailUpdate.SetTableView(PerDiem);
                    PerDiemDetailUpdate.RunModal();
                end;
            }
        }

    }
}
