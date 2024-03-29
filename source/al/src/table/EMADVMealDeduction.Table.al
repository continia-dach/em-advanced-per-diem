table 62081 "EMADV Meal Deduction"
{
    Caption = 'EMADV Meal Deduction';
    DataClassification = CustomerContent;
    LookupPageId = "EMADV Meal Deduction List";
    DrillDownPageId = "EMADV Meal Deduction List";
    PasteIsValid = true;

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
        field(9; "Domestic Day"; Boolean)
        {
            Caption = 'Domestic Day';
            DataClassification = CustomerContent;
        }
        field(10; "Deduction Type"; Enum "EMADV Meal Deduction Types")
        {
            Caption = 'Meal deduction type';
            DataClassification = CustomerContent;
        }
        field(11; "Deduction Method"; enum "EMADV Meal Deduction Method")
        {
            Caption = 'Deduction method';
            DataClassification = CustomerContent;
        }

        field(62080; "Breakfast Deduction"; Decimal)
        {
            Caption = 'Breakfast deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62081; "Breakfast-Lunch Deduction"; Decimal)
        {
            Caption = 'Breakfast & Lunch deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62082; "Breakfast-Dinner Deduction"; Decimal)
        {
            Caption = 'Breakfast & Dinner deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62083; "All meal Deduction"; Decimal)
        {
            Caption = 'All meal deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62084; "Lunch Deduction"; Decimal)
        {
            Caption = 'Lunch deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62085; "Lunch-Dinner Deduction"; Decimal)
        {
            Caption = 'Lunch & Dinner deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
        field(62086; "Dinner Deduction"; Decimal)
        {
            Caption = 'Dinner deduction';
            DecimalPlaces = 2 : 5;
            BlankZero = true;
        }
    }
    keys
    {
        key(PK; "Per Diem Group Code", "Destination Country/Region", "Accommodation Allowance Code", "Start Date", "Domestic Day", "Deduction Type")

        {
            Clustered = true;
        }
    }
}
