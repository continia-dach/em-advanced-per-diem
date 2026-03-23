report 62080 "EMADV Update Per Diem Calc."
{
    ApplicationArea = All;
    Caption = 'EM Update Per Diem Calculations';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(PerDiem; "CEM Per Diem")
        {
            RequestFilterFields = "Entry No.", "Departure Date/Time", Posted, "Posting Date";

            trigger OnPreDataItem()
            begin
                UpdateProcessCount := 0;
                ProcessedCount := 0;
                Message('Processing Per Diems...');
            end;

            trigger OnAfterGetRecord()
            var
                PerDiemDetail: Record "CEM Per Diem Detail";
                PerDiemValidate: Codeunit "CEM Per Diem-Validate";
            begin
                ProcessedCount += 1;

                PerDiemDetail.Reset();
                PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
                PerDiemDetail.SetRange("Accom. Allowance Amount (LCY)", 0);
                PerDiemDetail.SetRange("Daily Meal Allow. Amount (LCY)", 0);
                PerDiemDetail.SetRange("Breakfast Deduction Amt. (LCY)", 0);
                PerDiemDetail.SetRange("Lunch Deduction Amount (LCY)", 0);
                PerDiemDetail.SetRange("Dinner Deduction Amount (LCY)", 0);
                PerDiemDetail.SetRange("Omitted Deduct. Amount (LCY)", 0);
                PerDiemDetail.SetRange("Drinks Allowance Amount (LCY)", 0);
                PerDiemDetail.SetRange("Ent. Allowance Amt. (LCY)", 0);
                PerDiemDetail.SetRange("Transp. Allowance Amount (LCY)", 0);
                PerDiemDetail.SetFilter("Amount (LCY)", '>%1', 0);

                if not PerDiemDetail.IsEmpty() then begin
                    PerDiemValidate.Run(PerDiem);
                    UpdateProcessCount += 1;
                end;
            end;

            trigger OnPostDataItem()
            begin
                Message('Completed.' + '\' + 'Per Diems processed: ' + Format(ProcessedCount) + '\' + 'Per Diems updated: ' + Format(UpdateProcessCount));
            end;
        }
    }


    var
        UpdateProcessCount: Integer;
        ProcessedCount: Integer;
}
