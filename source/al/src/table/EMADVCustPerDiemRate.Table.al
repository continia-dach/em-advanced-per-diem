table 62080 "EMADV Cust PerDiem Rate"
{
    Caption = 'EMADV Custom Per Diem Rate';
    DataClassification = CustomerContent;
    LookupPageId = "EMADV Cust PD Rates";
    DrillDownPageId = "EMADV Cust PD Rates";

    fields
    {
        field(1; "Per Diem Group Code"; Code[20])
        {
            Caption = 'Per Diem Group Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "CEM Per Diem Group";
        }
        field(2; "Destination Country/Region"; Code[10])
        {
            Caption = 'Destination Country/Region';
            DataClassification = CustomerContent;
            TableRelation = "CEM Country/Region";
        }
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; "Accommodation Allowance Code"; Code[20])
        {
            Caption = 'Accommodation Allowance Code';
            DataClassification = CustomerContent;
            TableRelation = "CEM Allowance" WHERE(Type = FILTER(' ' | Accommodation));
        }
        field(5; "Calculation Method"; Enum "EMADV Per Diem Calc. Method")
        {
            Caption = 'Calculation method';
            DataClassification = CustomerContent;
        }
        field(6; "From Hour"; Integer)
        {
            Caption = 'From Hour';
            MinValue = 0;
            MaxValue = 23;
            DataClassification = CustomerContent;
        }
        field(10; "Daily Accommodation Allowance"; Decimal)
        {
            Caption = 'Tax-Free Accommodation Allowance';
            DataClassification = CustomerContent;
        }
        field(11; "Daily Meal Allowance"; Decimal)
        {
            Caption = 'Tax-Free Meal Allowance';
            DataClassification = CustomerContent;
        }
        field(20; "Breakfast deduction"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(Breakfast)
                                                                                         ));
        }
        field(21; "Breakfast-Lunch Ded."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(BreakfastLunch)
                                                                                         ));
        }
        field(22; "Breakfast-Lunch-Dinner Ded."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(BreakfastLunchDinner)
                                                                                         ));
        }
        field(23; "Lunch Ded."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(Lunch)
                                                                                         ));
        }
        field(24; "Lunch-Dinner Ded."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(LunchDinner)
                                                                                         ));
        }
        field(25; "Dinner Ded."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("EMADV Cust PerDiem Rate Detail"."Deduction Amount" where("Per Diem Group Code" = field("Per Diem Group Code"),
                                                                                         "Destination Country/Region" = field("Destination Country/Region"),
                                                                                         "Start Date" = field("Start Date"),
                                                                                         "Accommodation Allowance Code" = field("Accommodation Allowance Code"),
                                                                                         "Calculation Method" = field("Calculation Method"),
                                                                                         "Deduction Type" = const(Dinner)
                                                                                         ));
        }
    }
    keys
    {
        key(PK; "Per Diem Group Code", "Destination Country/Region", "Start Date", "Accommodation Allowance Code", "Calculation Method", "From Hour")
        {
            Clustered = true;
        }
    }

    internal procedure GetDeductionAmount(var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    begin
        if PerDiemDetail.Breakfast and PerDiemDetail.Lunch and PerDiemDetail.Dinner then begin
            Rec.CalcFields("Breakfast-Lunch-Dinner Ded.");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Breakfast-Lunch-Dinner Ded."));
            exit(true);
        end;

        if PerDiemDetail.Breakfast and PerDiemDetail.Lunch and (not PerDiemDetail.Dinner) then begin
            Rec.CalcFields("Breakfast-Lunch Ded.");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Breakfast-Lunch Ded."));
            exit(true);
        end;

        if PerDiemDetail.Breakfast and (not PerDiemDetail.Lunch) and (not PerDiemDetail.Dinner) then begin
            Rec.CalcFields("Breakfast deduction");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Breakfast deduction"));
            exit(true);
        end;

        if (not PerDiemDetail.Breakfast) and PerDiemDetail.Lunch and PerDiemDetail.Dinner then begin
            Rec.CalcFields("Lunch-Dinner Ded.");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Lunch-Dinner Ded."));
            exit(true);
        end;


        if (not PerDiemDetail.Breakfast) and PerDiemDetail.Lunch and (not PerDiemDetail.Dinner) then begin
            Rec.CalcFields("Lunch Ded.");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Lunch Ded."));
            exit(true);
        end;

        if (not PerDiemDetail.Breakfast) and (not PerDiemDetail.Lunch) and PerDiemDetail.Dinner then begin
            Rec.CalcFields("Dinner Ded.");
            PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(Rec."Dinner Ded."));
            exit(true);
        end;

        PerDiemDetail.Validate("Meal Allowance Amount", CalcPerDiemDetailAmount(0));
        PerDiemDetail.Validate("Accommodation Allowance Amount", Rec."Daily Accommodation Allowance");
        exit(true);
    end;

    local procedure CalcPerDiemDetailAmount(DeductionAmt: Decimal): Decimal
    begin
        if (DeductionAmt >= Rec."Daily Meal Allowance") then
            exit(0)
        else
            exit(Rec."Daily Meal Allowance" - DeductionAmt);
    end;

    trigger OnDelete()
    var
        CustPerDiemRateDetail: Record "EMADV Cust PerDiem Rate Detail";
    begin
        CustPerDiemRateDetail.SetRange("Per Diem Group Code", Rec."Per Diem Group Code");
        CustPerDiemRateDetail.SetRange("Destination Country/Region", Rec."Destination Country/Region");
        CustPerDiemRateDetail.SetRange("Start Date", Rec."Start Date");
        CustPerDiemRateDetail.SetRange("Accommodation Allowance Code", Rec."Accommodation Allowance Code");
        CustPerDiemRateDetail.SetRange("Calculation Method", Rec."Calculation Method"::FirstDay);
        CustPerDiemRateDetail.SetRange("From Hour", Rec."From Hour");
        if not CustPerDiemRateDetail.IsEmpty() then
            CustPerDiemRateDetail.DeleteAll(true);
    end;
}
