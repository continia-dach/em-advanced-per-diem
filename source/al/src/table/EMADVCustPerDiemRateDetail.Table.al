table 62081 "EMADV Cust PerDiem Rate Detail"
{
    Caption = 'EMADV Custom Per Diem Rates';
    DataClassification = CustomerContent;
    LookupPageId = "EMADV Cust. PD Rate Details";

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
        field(6; "Deduction Type"; Option)
        {
            Caption = 'Deduction Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Breakfast,Breakfast+Lunch,Breakfast+Lunch+Dinner,Lunch,Lunch+Dinner,Dinner,Others';
            OptionMembers = Breakfast,BreakfastLunch,BreakfastLunchDinner,Lunch,LunchDinner,Dinner,Others;
        }
        field(10; "Deduction Amount"; Decimal)
        {
            Caption = 'Deduction Amount';
            DataClassification = CustomerContent;
        }

        field(11; "Deduction Description"; Decimal)
        {
            Caption = 'Deduction Description';
            DataClassification = CustomerContent;
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
