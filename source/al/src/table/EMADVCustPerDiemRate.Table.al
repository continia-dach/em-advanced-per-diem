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
        field(5; "Calculation Method"; Option)
        {
            Caption = 'Calculation method';
            DataClassification = CustomerContent;
            OptionCaption = 'Full Day,First/Last Day';
            OptionMembers = FullDay,FirstLastDay;

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
        field(21; "Breakfast-Lunch Amt."; Decimal)
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
        field(22; "Breakfast-Lunch-Dinner Amt."; Decimal)
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
    }
    keys
    {
        key(PK; "Per Diem Group Code", "Destination Country/Region", "Start Date", "Accommodation Allowance Code", "Calculation Method")
        {
            Clustered = true;
        }
    }
}
