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

            action("Update Per Diem Details")
            {
                ApplicationArea = All;
                Caption = 'Update Per Diem Details';
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

            action("Reset Per Diem Details")
            {
                ApplicationArea = All;
                Caption = 'Reset Per Diem Details';
                Image = ResetStatus;
                ToolTip = 'Reset the Per Diem details for the selected entry.';

                trigger OnAction()
                var
                    PerDiemDetails: Record "CEM Per Diem Detail";
                begin
                    if Confirm('Sollen die Details zurückgesetzt werden?', false) then begin
                        //PerDiemDetails.ModifyAll("Accom. Allowance Amount (LCY)", 0);

                        PerDiemDetails.ModifyAll("Daily Meal Allowance Amount", 0);
                        PerDiemDetails.ModifyAll("Daily Meal Allow. Amount (LCY)", 0);

                        PerDiemDetails.ModifyAll("Tax. Daily Meal Allow. Amount", 0);
                        PerDiemDetails.ModifyAll("Tax. Dly. M. Allow. Amt. (LCY)", 0);

                        /*
                        PerDiemDetails.ModifyAll("Breakfast Deduction Amt. (LCY)", 0);
                        PerDiemDetails.ModifyAll("Lunch Deduction Amount (LCY)", 0);
                        PerDiemDetails.ModifyAll("Dinner Deduction Amount (LCY)", 0);
                        PerDiemDetails.ModifyAll("Omitted Deduct. Amount (LCY)", 0);
                        PerDiemDetails.ModifyAll("Drinks Allowance Amount (LCY)", 0);
                        PerDiemDetails.ModifyAll("Ent. Allowance Amt. (LCY)", 0);
                        PerDiemDetails.ModifyAll("Transp. Allowance Amount (LCY)", 0);
                        */
                        CurrPage.Update(false);
                    end;
                end;
            }
        }

    }
}
