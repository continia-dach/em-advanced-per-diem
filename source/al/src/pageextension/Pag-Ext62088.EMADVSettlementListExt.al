pageextension 62088 "EMADV Settlement List Ext" extends "CEM Settlement List"
{
    layout
    {
        addafter(AmountLCY)
        {
            field(TaxableAmountLCY; GetTaxableAmountLCY())

            {
                ApplicationArea = All;
                Style = Attention;
                StyleExpr = StyleFormat;
                Caption = 'Taxable Amount (LCY)';
                ToolTip = 'Shows the taxable amount in LCY.';
            }
        }
    }

    var
        StyleFormat: Text[30];

    local procedure GetTaxableAmountLCY() TaxableAmount: Decimal
    var
        Mileage: Record "CEM Mileage";
        PerDiem: Record "CEM Per Diem";
    begin
        // Calculate taxable amount from Mileage table
        Mileage.SetCurrentKey("Settlement No.");
        Mileage.SetRange("Settlement No.", Rec."No.");
        if Mileage.FindSet() then
            repeat
                TaxableAmount += Mileage."Taxable Amount (LCY)";
            until Mileage.Next() = 0;

        // Calculate taxable amount from Per Diem table
        PerDiem.SetCurrentKey("Settlement No.");
        PerDiem.SetRange("Settlement No.", Rec."No.");
        if PerDiem.FindSet() then
            repeat
                PerDiem.CalcFields("Taxable Amount (LCY)");
                TaxableAmount += PerDiem."Taxable Amount (LCY)";
            until PerDiem.Next() = 0;
    end;

    trigger OnAfterGetRecord()
    begin

        case Rec.Status of
            Rec.Status::Open:
                StyleFormat := 'Attention';
            Rec.Status::Released:
                StyleFormat := 'Favorable';
            else
                StyleFormat := 'None';
        END;
    end;
}
