unit umeUnits;

interface

uses SysUtils, Windows;

(*
* Формат идентификаторов (XXXX соотв. одному байту)
*  XXXX XXXX XXXX XXXX  XXXX XXXX XXXX XXXX
*                                      ---- Код системы единиц (СИ, дюймовая етс)
*                            ---- ---- Категория (ускорение, скорость етс)
*                        ---- Коэффициент (10^x), знаковая величина
*  ---- ---- ---- ---- Идентификатор единицы измерения

#define MEUNITS_MAKE_UNIT_ID(sys,cat,coef,id) ((((UINT64)id) << 32) + ((sys) & 0xFF) + (((cat) & 0xFFFF) << 8) + (((UINT)(((char)coef) & 0xFF)) << 24))
#define MEUNITS_GET_CATEGORY(id) ((UINT)(((id) >> 8) & 0xFFFF))
#define MEUNITS_GET_COEFF(id) ((char)(((id) >> 24) & 0xFF))
#define MEUNITS_GET_SYS(id) ((char)((id) & 0xFF))
*)

const
  /// Системы единиц
  ID_ME_SYSTEM_SI : Byte    = 1;
  ID_ME_SYSTEM_UK : Byte    = 2;
  ID_ME_SYSTEM_OTHER : Byte = 15;

  /// Категории
  ID_ME_CAT_NONDIM : Word     = 1;   /// Безразмерные величины
  ID_ME_CAT_PART : Word	      = 3;   /// Доли (%,ppm)
  ID_ME_CAT_TIME : Word       = 5;   /// Время
  ID_ME_CAT_FREQ : Word       = 6;   /// Частота
  ID_ME_CAT_LENGTH : Word     = 10;  /// Расстояние
  ID_ME_CAT_SQUARE : Word     = 11;  /// Площадь
  ID_ME_CAT_VOLUME : Word     = 12;  /// Объем
  ID_ME_CAT_DENSITY : Word    = 13;  /// Плотность
  ID_ME_CAT_ANGLE : Word      = 14;  /// Угол
  ID_ME_CAT_SPEED : Word      = 20;  /// Скорость
  ID_ME_CAT_ACCEL : Word      = 21;  /// Ускорение
  ID_ME_CAT_MASS : Word       = 30;  /// Масса
  ID_ME_CAT_FORCE : Word      = 31;  /// Сила
  ID_ME_CAT_TORQUE : Word     = 32;  /// Момент силы
  ID_ME_CAT_PRESSURE : Word   = 33;  /// Давление
  ID_ME_CAT_REL_STRAIN : Word = 37;  /// Отн. деформация
  ID_ME_CAT_ENERGY : Word     = 40;  /// Энергия
  ID_ME_CAT_POWER : Word      = 41;  /// Мощность
  ID_ME_CAT_TEMPER : Word     = 42;  /// Температура
  ID_ME_CAT_VOLTAGE : Word    = 50;  /// Напряжение
  ID_ME_CAT_CURRENT : Word    = 51;  /// Ток
  ID_ME_CAT_RESIST : Word     = 52;  /// Сопротивление
  ID_ME_CAT_CHARGE : Word     = 53;  /// Заряд
  ID_ME_CAT_REL_VOLTAGE : Word= 54;  /// Отн. напряжение

  /// Величины
  ID_ME_TYPE_UNKNOWN : Word  = 0;
  ID_ME_TYPE_NONDIM : Word   = 1;      /// Безразмерные величины
  ID_ME_TYPE_DB : Word       = 2;      /// Отн. уровень (дБ)
  ID_ME_TYPE_PART : Word     = 3;      /// Доли
  ID_ME_TYPE_TIME : Word     = 5;      /// Время
  ID_ME_TYPE_REL_STRAIN : Word = 7;    /// Отн. деформация
  ID_ME_TYPE_FREQ : Word     = 10;     /// Частота
  ID_ME_TYPE_ROTATION : Word = 11;     /// Частота вращения
  ID_ME_TYPE_LENGTH : Word   = 20;     /// Расстояние
  ID_ME_TYPE_SQUARE : Word   = 30;     /// Площадь
  ID_ME_TYPE_VOLUME : Word   = 40;     /// Объем
  ID_ME_TYPE_DENSITY : Word  = 50;     /// Плотность
  ID_ME_TYPE_ANGLE : Word    = 60;     /// Угол
  ID_ME_TYPE_SPEED : Word    = 70;     /// Скорость
  ID_ME_TYPE_ACCEL : Word    = 80;     /// Ускорение
  ID_ME_TYPE_MASS : Word     = 90;     /// Масса
  ID_ME_TYPE_FORCE : Word    = 100;    /// Сила
  ID_ME_TYPE_TORQUE : Word   = 110;    /// Момент вращения
  ID_ME_TYPE_PRESSURE : Word = 120;    /// Давление
  ID_ME_TYPE_STRESS : Word   = 125;    /// Мех.напряжение
  ID_ME_TYPE_ENERGY : Word   = 130;    /// Энергия
  ID_ME_TYPE_POWER : Word    = 140;    /// Мощность
  ID_ME_TYPE_TEMPER : Word   = 150;    /// Температура
  ID_ME_TYPE_VOLTAGE : Word  = 160;    /// Напряжение
  ID_ME_TYPE_CURRENT : Word  = 170;    /// Ток
  ID_ME_TYPE_RESIST : Word   = 180;    /// Сопротивление
  ID_ME_TYPE_CHARGE : Word   = 190;    /// Заряд
  ID_ME_TYPE_REL_VOLTAGE : Word = 200; /// Отн. напряжение (мВ/В)

  /// Функции
  ID_ME_FUNC_UNKNOWN : Word                           = 0;
  ID_ME_FUNC_TIME_RESPONSE : Word                     = 1;    /// 1 - Time Response
  ID_ME_FUNC_AUTO_SPECTRUM : Word                     = 2;    /// 2 - Auto Spectrum
  ID_ME_FUNC_CROSS_SPECTRUM : Word                    = 3;    /// 3 - Cross Spectrum
  ID_ME_FUNC_FREQUENCY_RESPONSE : Word                = 4;    /// 4 - Frequency Response Function
  ID_ME_FUNC_TRANSMISSIBILITY : Word                  = 5;    /// 5 - Transmissibility
  ID_ME_FUNC_COHERENCE : Word                         = 6;    /// 6 - Coherence
  ID_ME_FUNC_AUTO_CORRELATION : Word                  = 7;    /// 7 - Auto Correlation
  ID_ME_FUNC_CROSS_CORRELATION : Word                 = 8;    /// 8 - Cross Correlation
  ID_ME_FUNC_POWER_SPECTRAL_DENSITY : Word            = 9;    /// 9 - Power Spectral Density (PSD)
  ID_ME_FUNC_ENERGY_SPECTRAL_DENSITY : Word           = 10;   /// 10 - Energy Spectral Density (ESD)
  ID_ME_FUNC_PROBABILITY_DENSITY : Word               = 11;   /// 11 - Probability Density Function
  ID_ME_FUNC_SPECTRUM : Word                          = 12;   /// 12 - Spectrum
  ID_ME_FUNC_CUMULATIVE_FREQUENCY_DISTRIBUTION : Word = 13;   /// 13 - Cumulative Frequency Distribution
  ID_ME_FUNC_PEAKS_VALLEY : Word                      = 14;   /// 14 - Peaks Valley
  ID_ME_FUNC_STRESS_CYCLES : Word                     = 15;   /// 15 - Stress/Cycles
  ID_ME_FUNC_STRAIN_CYCLES : Word                     = 16;   /// 16 - Strain/Cycles
  ID_ME_FUNC_ORBIT : Word                             = 17;   /// 17 - Orbit
  ID_ME_FUNC_MODE_INDICATION : Word                   = 18;   /// 18 - Mode Indicator Function
  ID_ME_FUNC_FORCE_PATTERN : Word                     = 19;   /// 19 - Force Pattern
  ID_ME_FUNC_PARTIAL_POWER : Word                     = 20;   /// 20 - Partial Power
  ID_ME_FUNC_PARTIAL_COHERENCE : Word                 = 21;   /// 21 - Partial Coherence
  ID_ME_FUNC_EIGENVALUE : Word                        = 22;   /// 22 - Eigenvalue
  ID_ME_FUNC_EIGENVECTOR : Word                       = 23;   /// 23 - Eigenvector
  ID_ME_FUNC_SHOCK_RESPONSE_SPECTRUM : Word           = 24;   /// 24 - Shock Response Spectrum
  ID_ME_FUNC_FIR_FILRER : Word                        = 25;   /// 25 - Finite Impulse Response Filter
  ID_ME_FUNC_MULTIPLE_COHERENSE : Word                = 26;   /// 26 - Multiple Coherence
  ID_ME_FUNC_ORDER_FUNCTION : Word                    = 27;   /// 27 - Order Function
  ID_ME_FUNC_PHASE_COMPENSATION : Word                = 28;   /// 28 - Phase Compensation
  ID_ME_FUNC_BITSIGNAL : Word                         = 29;   /// 29
  ID_ME_FUNC_SPECTRUM_A : Word                        = 100;  /// Амплитудный спектр
  ID_ME_FUNC_SPECTRUM_P : Word                        = 101;  /// Спектр мощности
  ID_ME_FUNC_REAL : Word                              = 104;  /// Действительная часть
  ID_ME_FUNC_IMAGE : Word                             = 105;  /// Мнимая часть
  ID_ME_FUNC_PHASE : Word                             = 106;  /// Фаза
  ID_ME_FUNC_CAMPBELL_DIAGRAM : Word                  = 200;  /// диаграмма Кемпбелла
  ID_ME_FUNC_PROBABILITY : Word                       = 300;  /// вероятность попадания

  /// Оси
  ID_ME_AXIS_X : UInt32 = 0;
  ID_ME_AXIS_Y : UInt32 = 1;
  ID_ME_AXIS_Z : UInt32 = 2;

  ID_ME_UNIT_UNKNOWN : UInt64    = 0;

Type
  Measure_Type = record
    Category  : String; // тип измерения
    NameShort : String; // название единицы короткое
    NameFull  : String; // название единицы длинное

    ID_System : Int64; // константы для расчета ID
    ID_Category : Int64;
    ID_Coef : Int64;
    ID_id : Int64;

    ID : Int64;            // ID единицы измерения
    ID_NoCategory : Int64; // ID единицы измерения без категории
End;

var
  Measure_TypeArray : array [0..130] of Measure_Type;

  MEUNITS_LanguageIndex : Integer = 0; // Russian

  procedure Fill_Measure_TypeArray;
  function MEUNITS_GET_ID_ByNameShort(const NameShort : String; out id : Int64) : HRESULT;
  function MEUNITS_GET_ID_ByNameFull(const NameFull : String; out id : Int64) : HRESULT;
  function MEUNITS_GET_NameShort_ByID(const id : Int64; out NameShort : String) : HRESULT;
  function MEUNITS_GET_NameFull_ByID(const id : Int64; out NameFull : String) : HRESULT;

implementation

procedure Fill_Measure_TypeArray;
var
  index : Integer;
    procedure MEUNITS_MAKE_UNIT_ID(Category, NameShort, NameFull : String;
                                   ID_System, ID_Category, ID_Coef, ID_id : Int64);
      begin
        if index >= Length(Measure_TypeArray) then
          begin
            MessageBox(0, PChar('Неверный индекс массива ' + IntToStr(index) + '!'), PChar('Неверный индекс массива'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
            Abort;
          end;

        Measure_TypeArray[index].Category  := Category;
        Measure_TypeArray[index].NameShort := NameShort;
        Measure_TypeArray[index].NameFull  := NameFull;

        Measure_TypeArray[index].ID_System   := ID_System;
        Measure_TypeArray[index].ID_Category := ID_Category;
        Measure_TypeArray[index].ID_Coef     := ID_Coef;

        // define MEUNITS_MAKE_UNIT_ID(sys,cat,coef,id) ((((UINT64)id) << 32) + ((sys) & 0xFF) + (((cat) & 0xFFFF) << 8) + (((UINT)(((char)coef) & 0xFF)) << 24))
        Measure_TypeArray[index].ID :=
        (Int64(ID_id) Shl 32) + (ID_System and $FF) + (((ID_Category) and $FFFF) Shl 8) + UINT(Byte(ID_Coef) and $FF) Shl 24;

        // без категории
        Measure_TypeArray[index].ID_NoCategory :=
        (Int64(ID_id) Shl 32) + (ID_System and $FF) + (((ID_ME_CAT_NONDIM) and $FFFF) Shl 8) + UINT(Byte(ID_Coef) and $FF) Shl 24;

        index := index + 1;
      end;
begin
  //if Measure_TypeArray[0].Category <> '' then Exit;

  index := 0; // meUnits_consts.h, meUnits.rc

  case MEUNITS_LanguageIndex of
    1 : begin // English
      // Безразмерные величины
      MEUNITS_MAKE_UNIT_ID('Dimensionless quantity', '', '', ID_ME_SYSTEM_OTHER, ID_ME_CAT_NONDIM, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Dimensionless quantity', '', '', ID_ME_SYSTEM_OTHER, ID_ME_CAT_NONDIM, 0, 2);

      // Доли
      MEUNITS_MAKE_UNIT_ID('Fraction', '%',        'percent',    ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Fraction', 'permille', 'per mille',  ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART, -1, 2);
      MEUNITS_MAKE_UNIT_ID('Fraction', 'ppm',      'millionths', ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART, -4, 3);

      // Время
      MEUNITS_MAKE_UNIT_ID('Time', 's',   'seconds',      ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  1);
      MEUNITS_MAKE_UNIT_ID('Time', 'min', 'minutes',      ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  2);
      MEUNITS_MAKE_UNIT_ID('Time', 'h',   'hours',        ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  3);
      MEUNITS_MAKE_UNIT_ID('Time', 'd',   'days',         ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  4);
      MEUNITS_MAKE_UNIT_ID('Time', 'm',   'months',       ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  5);
      MEUNITS_MAKE_UNIT_ID('Time', 'y',   'years',        ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, 0,  6);
      MEUNITS_MAKE_UNIT_ID('Time', 'ms',  'milliseconds', ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Time', 'µs',  'microseconds', ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Time', 'ns',  'nanoseconds',  ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -9, 13);

      // Частота
      MEUNITS_MAKE_UNIT_ID('Frequency', 'Hz',  'Hertz',                  ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Frequency', 'kHz', 'kilohertz',              ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Frequency', 'MHz', 'Megahertz',              ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 6, 3);
      MEUNITS_MAKE_UNIT_ID('Frequency', 'GHz', 'Gigahertz',              ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 9, 4);
      MEUNITS_MAKE_UNIT_ID('Frequency', 'rpm', 'revolutions per minute', ID_ME_SYSTEM_OTHER, ID_ME_CAT_FREQ, 0, 1);

      // Длина (расстояние)
      MEUNITS_MAKE_UNIT_ID('Length', 'm',   'meter',       ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, 0,  1);
      MEUNITS_MAKE_UNIT_ID('Length', 'km',  'kilometer',   ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, 3,  2);
      MEUNITS_MAKE_UNIT_ID('Length', 'cm',  'centimeter',  ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -2, 11);
      MEUNITS_MAKE_UNIT_ID('Length', 'mm',  'millimeters', ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -3, 12);
      MEUNITS_MAKE_UNIT_ID('Length', 'μm',  'micrometers', ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -6, 13);
      MEUNITS_MAKE_UNIT_ID('Length', 'nm',  'nanometer',   ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Length', 'inch', 'inch',        ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH,  0, 21);
      MEUNITS_MAKE_UNIT_ID('Length', 'mile', 'miles',       ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH, -3, 22);
      MEUNITS_MAKE_UNIT_ID('Length', 'foot', 'feet',        ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH,  0, 23);

      // Отн. деформация
      MEUNITS_MAKE_UNIT_ID('Relative strain', 'm/m',  'meter per meter',       ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Relative strain', 'mm/m', 'millimeters per meter', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -3, 2);
      MEUNITS_MAKE_UNIT_ID('Relative strain', 'µm/m', 'micrometers per meter', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -6, 3);
      MEUNITS_MAKE_UNIT_ID('Relative strain', 'µE',   'micrograin',            ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -6, 4); // синоним

      // Площадь
      MEUNITS_MAKE_UNIT_ID('Area', 'm2', 'square meters', ID_ME_SYSTEM_SI, ID_ME_CAT_SQUARE, 0, 1);

      // Объем
      MEUNITS_MAKE_UNIT_ID('Volume', 'm^3', 'cubic meters', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLUME, 0, 1);

      // Плотность
      MEUNITS_MAKE_UNIT_ID('Density', 'kg/m^3', 'kilograms per cubic meter', ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Density', 'kg/l',   'kilograms per liter',       ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Density', 't/m^3',  'tons per cubic meter',      ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 3, 3);

      // Угол
      MEUNITS_MAKE_UNIT_ID('Angle', '°',     'degrees', ID_ME_SYSTEM_SI, ID_ME_CAT_ANGLE, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Angle', 'Queue', 'radian',  ID_ME_SYSTEM_SI, ID_ME_CAT_ANGLE, 0, 2);

      // Скорость
      MEUNITS_MAKE_UNIT_ID('Speed', 'm/s',      'meters per second',      ID_ME_SYSTEM_SI,    ID_ME_CAT_SPEED,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Speed', 'km/s',     'kilometers per second',  ID_ME_SYSTEM_SI,    ID_ME_CAT_SPEED,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Speed', 'mm/s',     'millimeters per second', ID_ME_SYSTEM_SI,    ID_ME_CAT_SPEED, -3, 3);
      MEUNITS_MAKE_UNIT_ID('Speed', 'km/h',     'kilometers per hour',    ID_ME_SYSTEM_OTHER, ID_ME_CAT_SPEED,  0, 4);
      MEUNITS_MAKE_UNIT_ID('Speed', 'inches/s', 'inches per second',      ID_ME_SYSTEM_UK,    ID_ME_CAT_SPEED,  0, 10);
      MEUNITS_MAKE_UNIT_ID('Speed', 'ft/s',     'ft per second',          ID_ME_SYSTEM_UK,    ID_ME_CAT_SPEED,  0, 11);

      // Ускорение
      MEUNITS_MAKE_UNIT_ID('Acceleration', 'm/s^2',        'meters per second squared', ID_ME_SYSTEM_SI,    ID_ME_CAT_ACCEL, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Acceleration', 'g',            'gravity acceleration',      ID_ME_SYSTEM_OTHER, ID_ME_CAT_ACCEL, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Acceleration', 'inches/sec^2', 'inches per second squared', ID_ME_SYSTEM_UK,    ID_ME_CAT_ACCEL, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Acceleration', 'ft/s^2',       'ft per second squared',     ID_ME_SYSTEM_UK,    ID_ME_CAT_ACCEL, 0, 2);

      // Масса
      MEUNITS_MAKE_UNIT_ID('Mass', 'kg',  'kilogram',      ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Mass', 'c',   'hundredweight', ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  2, 2);
      MEUNITS_MAKE_UNIT_ID('Mass', 't',   'tons',          ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  3, 3);
      MEUNITS_MAKE_UNIT_ID('Mass', 'kt',  'kilotons',      ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  6, 4);
      MEUNITS_MAKE_UNIT_ID('Mass', 'Mt',  'megatons',      ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  9, 5);
      MEUNITS_MAKE_UNIT_ID('Mass', 'g',   'grams',         ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Mass', 'mg',  'milligrams',    ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Mass', 'µg',  'micrograms',    ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -9, 13);

      // Сила
      MEUNITS_MAKE_UNIT_ID ('Force', 'N',   'Newton',         ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 1);
      MEUNITS_MAKE_UNIT_ID ('Force', 'kN',  'kilonewton',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  3, 2);
      MEUNITS_MAKE_UNIT_ID ('Force', 'MN',  'meganewton',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  6, 3);
      MEUNITS_MAKE_UNIT_ID ('Force', 'mN',  'millinewton',    ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -3, 11);
      MEUNITS_MAKE_UNIT_ID ('Force', 'µН',  'micronewton',    ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -6, 12);
      MEUNITS_MAKE_UNIT_ID ('Force', 'nN',  'Nanonewton',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -9, 13);
      MEUNITS_MAKE_UNIT_ID ('Force', 'kgf', 'kilogram-force', ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 14);
      MEUNITS_MAKE_UNIT_ID ('Force', 'Tf',  'ton-force',      ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 15);
      MEUNITS_MAKE_UNIT_ID ('Force', 'gf',  'gram-force',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 16);

      // Момент силы
      MEUNITS_MAKE_UNIT_ID ('Moment of force', 'NM', 'newton meter', ID_ME_SYSTEM_SI, ID_ME_CAT_TORQUE, 0, 1);

      // Давление
      MEUNITS_MAKE_UNIT_ID('Pressure', 'Pa',       'Pascal',                                 ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'kPa',      'Kilopascals',                            ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'MPa',      'Megapascals',                            ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'HPa',      'Gigapascals',                            ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'mPa',      'Millipascals',                           ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'μPa',      'Micropascals',                           ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'nPa',      'Nanopascals',                            ID_ME_SYSTEM_SI,    ID_ME_CAT_PRESSURE, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'bar',      'bars',                                   ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 20);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'mbar',     'millibars',                              ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 21);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'at',       'atmosphere, technical',                  ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 22);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'atm',      'atmospheres, standard',                  ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 23);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'kgf/mm^2', 'kilogram-forces per millimeter squared', ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 24);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'kgf/cm^2', 'kilogram-forces per centimeter squared', ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 25);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'kgf/m2',   'kilogram forces per meter squared',      ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 26);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'din/cm^2', 'din per centimeter squared',             ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 27);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'mmHg',     'Millimeters of mercury',                 ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 28);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'mmH2O',    'millimeters of water column',            ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 29);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'mH2O',     'meters of water column',                 ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 30);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'psi',      'pounds per square inch',                 ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  0, 31);
      MEUNITS_MAKE_UNIT_ID('Pressure', 'hPa',      'Hectopascals',                           ID_ME_SYSTEM_OTHER, ID_ME_CAT_PRESSURE,  2, 32);

      // Энергия
      MEUNITS_MAKE_UNIT_ID('Energy', 'J',  'Joules',     ID_ME_SYSTEM_SI, ID_ME_CAT_ENERGY, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Energy', 'kJ', 'kilojoules', ID_ME_SYSTEM_SI, ID_ME_CAT_ENERGY, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Energy', 'MJ', 'megajoules', ID_ME_SYSTEM_SI, ID_ME_CAT_ENERGY, 6, 3);

      // Мощность
      MEUNITS_MAKE_UNIT_ID('Power', 'W',  'watts',               ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Power', 'kW', 'kilowatts',           ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Power', 'MW', 'megawatts',           ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Power', 'GW', 'gigawatts',           ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Power', 'mW', 'milliwatts',          ID_ME_SYSTEM_SI, ID_ME_CAT_POWER, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Power', 'μW', 'microwatts',          ID_ME_SYSTEM_SI, ID_ME_CAT_POWER, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Power', 'hp', 'horsepower (metric)', ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  0, 13);

      // Температура
      MEUNITS_MAKE_UNIT_ID('Temperature', '°K', 'Kelvin degrees',     ID_ME_SYSTEM_SI,    ID_ME_CAT_TEMPER, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Temperature', '°C', 'degrees Celsius',    ID_ME_SYSTEM_OTHER, ID_ME_CAT_TEMPER, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Temperature', '°F', 'degrees Fahrenheit', ID_ME_SYSTEM_OTHER, ID_ME_CAT_TEMPER, 0, 2);

      // Напряжение
      MEUNITS_MAKE_UNIT_ID('Voltage', 'V',  'Volts',      ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'kV', 'kilovolts',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'MV', 'megavolts',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'GW', 'gigavolts',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'mV', 'millivolts', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'μV', 'microvolts', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Voltage', 'nV', 'Nanovolts',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -9, 13);

      // Ток
      MEUNITS_MAKE_UNIT_ID('Current', 'A',  'amperes',  ID_ME_SYSTEM_SI,  ID_ME_CAT_CURRENT,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Current', 'kA', 'kiloamps', ID_ME_SYSTEM_SI,  ID_ME_CAT_CURRENT,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Current', 'mA', 'milliamps', ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Current', 'μA', 'microamps', ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT, -6, 12);

      // Сопротивление
      MEUNITS_MAKE_UNIT_ID('Resistance', 'Ohms',  'ohms',                       ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'kOm',   'kilohms',                    ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'MOm',   'megaoms',                    ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'GOm',   'gigaoms',                    ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'mOm',   'millioms',                   ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'μOm',   'microhomes',                 ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'nOm',   'nanooms',                    ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Resistance', 'mV/mA', 'millivolts per milliampere', ID_ME_SYSTEM_OTHER, ID_ME_CAT_RESIST,  0, 16);

      // Заряд
      MEUNITS_MAKE_UNIT_ID('Charge', 'C',   'Coulombs',          ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, 0,  1);
      MEUNITS_MAKE_UNIT_ID('Charge', 'abC', 'abCoulombs',        ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  1,  2);
      MEUNITS_MAKE_UNIT_ID('Charge', 'kC',  'kiloCoulombs',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  3,  3);
      MEUNITS_MAKE_UNIT_ID('Charge', 'MC',  'megaCoulombs',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  6,  4);
      MEUNITS_MAKE_UNIT_ID('Charge', 'mC',  'milliCoulombs',     ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -3,  5);
      MEUNITS_MAKE_UNIT_ID('Charge', 'μC',  'microCoulombs',     ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -6,  6);
      MEUNITS_MAKE_UNIT_ID('Charge', 'nC',  'nanoCoulombs',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -9,  7);
      MEUNITS_MAKE_UNIT_ID('Charge', 'pC',  'picoCoulombs',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -12, 8);
      MEUNITS_MAKE_UNIT_ID('Charge', 'mAh', 'milliampere-hours', ID_ME_SYSTEM_OTHER, ID_ME_CAT_CHARGE,  0,  15);
      MEUNITS_MAKE_UNIT_ID('Charge', 'Ah',  'ampere-hours',      ID_ME_SYSTEM_OTHER, ID_ME_CAT_CHARGE,  0,  16);

      // Отн. напряжение
      MEUNITS_MAKE_UNIT_ID('Relative voltage', 'V/V',  'volt per volt',       ID_ME_SYSTEM_SI, ID_ME_CAT_REL_VOLTAGE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Relative voltage', 'mV/V', 'millivolts per volt', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_VOLTAGE, -3, 2);
    end;

    else begin // Russian
      // Безразмерные величины
      MEUNITS_MAKE_UNIT_ID('Безразмерная величина', '', '', ID_ME_SYSTEM_OTHER, ID_ME_CAT_NONDIM, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Безразмерная величина', '', '', ID_ME_SYSTEM_OTHER, ID_ME_CAT_NONDIM, 0, 2);

      // Доли
      MEUNITS_MAKE_UNIT_ID('Доля', '%',        'процент',         ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Доля', 'permille', 'промилле',        ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART, -1, 2);
      MEUNITS_MAKE_UNIT_ID('Доля', 'ppm',      'миллионные доли', ID_ME_SYSTEM_OTHER, ID_ME_CAT_PART, -4, 3);

      // Время
      MEUNITS_MAKE_UNIT_ID('Время', 'с',   'секунды',     ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  1);
      MEUNITS_MAKE_UNIT_ID('Время', 'мин', 'минуты',      ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  2);
      MEUNITS_MAKE_UNIT_ID('Время', 'ч',   'часы',        ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  3);
      MEUNITS_MAKE_UNIT_ID('Время', 'д',   'дни',         ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  4);
      MEUNITS_MAKE_UNIT_ID('Время', 'м',   'месяцы',      ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  5);
      MEUNITS_MAKE_UNIT_ID('Время', 'г',   'годы',        ID_ME_SYSTEM_SI, ID_ME_CAT_TIME,  0,  6);
      MEUNITS_MAKE_UNIT_ID('Время', 'мс',  'миллисекунды',ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Время', 'мкс', 'микросекунды',ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Время', 'нс',  'наносекунды', ID_ME_SYSTEM_SI, ID_ME_CAT_TIME, -9, 13);

      // Частота
      MEUNITS_MAKE_UNIT_ID('Частота', 'Гц',     'Герцы',            ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Частота', 'кГц',    'килогерцы',        ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Частота', 'МГц',    'мегагерцы',        ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 6, 3);
      MEUNITS_MAKE_UNIT_ID('Частота', 'ГГц',    'гигагерцы',        ID_ME_SYSTEM_SI,    ID_ME_CAT_FREQ, 9, 4);
      MEUNITS_MAKE_UNIT_ID('Частота', 'об/мин', 'обороты в минуту', ID_ME_SYSTEM_OTHER, ID_ME_CAT_FREQ, 0, 1);

      // Длина (расстояние)
      MEUNITS_MAKE_UNIT_ID('Длина', 'м',    'метры',      ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Длина', 'км',   'километры',  ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Длина', 'см',   'сантиметры', ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -2, 11);
      MEUNITS_MAKE_UNIT_ID('Длина', 'мм',   'миллиметры', ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -3, 12);
      MEUNITS_MAKE_UNIT_ID('Длина', 'мкм',  'микрометры', ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -6, 13);
      MEUNITS_MAKE_UNIT_ID('Длина', 'нм',   'нанометры',  ID_ME_SYSTEM_SI, ID_ME_CAT_LENGTH, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Длина', 'дюйм', 'дюймы',      ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH,  0, 21);
      MEUNITS_MAKE_UNIT_ID('Длина', 'мил',  'милы',       ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH, -3, 22);
      MEUNITS_MAKE_UNIT_ID('Длина', 'фут',  'футы',       ID_ME_SYSTEM_UK, ID_ME_CAT_LENGTH,  0, 23);

      // Отн. деформация
      MEUNITS_MAKE_UNIT_ID('Относительная деформация', 'м/м',   'метры на метр',      ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Относительная деформация', 'мм/м',  'миллиметры на метр', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -3, 2);
      MEUNITS_MAKE_UNIT_ID('Относительная деформация', 'мкм/м', 'микрометры на метр', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -6, 3);
      MEUNITS_MAKE_UNIT_ID('Относительная деформация', 'µЄ',    'микрострейн',        ID_ME_SYSTEM_SI, ID_ME_CAT_REL_STRAIN, -6, 4); // синоним

      // Площадь
      MEUNITS_MAKE_UNIT_ID('Площадь', 'м^2', 'квадратные метры', ID_ME_SYSTEM_SI, ID_ME_CAT_SQUARE, 0, 1);

      // Объем
      MEUNITS_MAKE_UNIT_ID('Объем', 'м^3', 'кубические метры', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLUME, 0, 1);

      // Плотность
      MEUNITS_MAKE_UNIT_ID('Плотность', 'кг/м^3', 'килограммы на кубический метр', ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Плотность', 'кг/л',   'килограммы на литр',            ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Плотность', 'т/м^3',  'тонны на кубический метр',      ID_ME_SYSTEM_SI, ID_ME_CAT_DENSITY, 3, 3);

      // Угол
      MEUNITS_MAKE_UNIT_ID('Угол', '°',   'градусы', ID_ME_SYSTEM_SI, ID_ME_CAT_ANGLE, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Угол', 'рад', 'радианы', ID_ME_SYSTEM_SI, ID_ME_CAT_ANGLE, 0, 2);

      // Скорость
      MEUNITS_MAKE_UNIT_ID('Скорость', 'м/с',    'метры в секунду', ID_ME_SYSTEM_SI,      ID_ME_CAT_SPEED,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Скорость', 'км/с',   'километры в секунду', ID_ME_SYSTEM_SI,  ID_ME_CAT_SPEED,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Скорость', 'мм/с',   'миллиметры в секунду', ID_ME_SYSTEM_SI, ID_ME_CAT_SPEED, -3, 3);
      MEUNITS_MAKE_UNIT_ID('Скорость', 'км/ч',   'километры в час', ID_ME_SYSTEM_OTHER,   ID_ME_CAT_SPEED,  0, 4);
      MEUNITS_MAKE_UNIT_ID('Скорость', 'дюйм/с', 'дюймы в секунду', ID_ME_SYSTEM_UK,      ID_ME_CAT_SPEED,  0, 10);
      MEUNITS_MAKE_UNIT_ID('Скорость', 'фут/с',  'футы в секунду', ID_ME_SYSTEM_UK,       ID_ME_CAT_SPEED,  0, 11);

      // Ускорение
      MEUNITS_MAKE_UNIT_ID('Ускорение', 'м/с^2',    'метры в секунду в квадрате',   ID_ME_SYSTEM_SI,ID_ME_CAT_ACCEL,    0, 1);
      MEUNITS_MAKE_UNIT_ID('Ускорение', 'g',        'ускорение свободного падения', ID_ME_SYSTEM_OTHER,ID_ME_CAT_ACCEL, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Ускорение', 'дюйм/с^2', 'дюймы в секунду в квадрате',   ID_ME_SYSTEM_UK,ID_ME_CAT_ACCEL,    0, 1);
      MEUNITS_MAKE_UNIT_ID('Ускорение', 'фут/с^2',  'футы в секунду в квадрате',    ID_ME_SYSTEM_UK,ID_ME_CAT_ACCEL,    0, 2);

      // Масса
      MEUNITS_MAKE_UNIT_ID('Масса', 'кг',  'килограммы',  ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Масса', 'ц',   'центнеры',    ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  2, 2);
      MEUNITS_MAKE_UNIT_ID('Масса', 'т',   'тонны',       ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  3, 3);
      MEUNITS_MAKE_UNIT_ID('Масса', 'кт',  'килотонны',   ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  6, 4);
      MEUNITS_MAKE_UNIT_ID('Масса', 'Мт',  'мегатонны',   ID_ME_SYSTEM_SI, ID_ME_CAT_MASS,  9, 5);
      MEUNITS_MAKE_UNIT_ID('Масса', 'г',   'граммы',      ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Масса', 'мг',  'миллиграммы', ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Масса', 'мкг', 'микрограммы', ID_ME_SYSTEM_SI, ID_ME_CAT_MASS, -9, 13);

      // Сила
      MEUNITS_MAKE_UNIT_ID('Сила', 'Н',   'ньютоны',        ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Сила', 'кН',  'килоньютоны',    ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Сила', 'МН',  'меганьютоны',    ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Сила', 'мН',  'миллиньютоны',   ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Сила', 'мкН', 'микроньютоны',   ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Сила', 'нН',  'наноньютоны',    ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Сила', 'кгс', 'килограмм-силы', ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 14);
      MEUNITS_MAKE_UNIT_ID('Сила', 'тс',  'тонна-силы',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 15);
      MEUNITS_MAKE_UNIT_ID('Сила', 'гс',  'грамм-силы',     ID_ME_SYSTEM_SI, ID_ME_CAT_FORCE,  0, 16);

      // Момент силы
      MEUNITS_MAKE_UNIT_ID('Момент силы', 'Н*м', 'ньютон-метры', ID_ME_SYSTEM_SI, ID_ME_CAT_TORQUE, 0, 1);

      // Давление
      MEUNITS_MAKE_UNIT_ID('Давление', 'Па',         'паскали',                                ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,    0, 1);
      MEUNITS_MAKE_UNIT_ID('Давление', 'кПа',        'килопаскали',                            ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,    3, 2);
      MEUNITS_MAKE_UNIT_ID('Давление', 'МПа',        'мегапаскали',                            ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,    6, 3);
      MEUNITS_MAKE_UNIT_ID('Давление', 'ГПа',        'гигапаскали',                            ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,    9, 4);
      MEUNITS_MAKE_UNIT_ID('Давление', 'мПа',        'миллипаскали',                           ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,   -3, 11);
      MEUNITS_MAKE_UNIT_ID('Давление', 'мкПа',       'микропаскали',                           ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,   -6, 12);
      MEUNITS_MAKE_UNIT_ID('Давление', 'нПа',        'нанопаскали',                            ID_ME_SYSTEM_SI,ID_ME_CAT_PRESSURE,   -9, 13);
      MEUNITS_MAKE_UNIT_ID('Давление', 'бар',        'бары',                                   ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 20);
      MEUNITS_MAKE_UNIT_ID('Давление', 'мбар',       'миллибары',                              ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 21);
      MEUNITS_MAKE_UNIT_ID('Давление', 'ат',         'атмосферы, технические',                 ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 22);
      MEUNITS_MAKE_UNIT_ID('Давление', 'атм',        'атмосферы, стандартные',                 ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 23);
      MEUNITS_MAKE_UNIT_ID('Давление', 'кгс/мм^2',   'килограмм-силы на миллиметр в квадрате', ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 24);
      MEUNITS_MAKE_UNIT_ID('Давление', 'кгс/см^2',   'килограмм-силы на сантиметр в квадрате', ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 25);
      MEUNITS_MAKE_UNIT_ID('Давление', 'кгс/м^2',    'килограмм-силы на метр в квадрате',      ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 26);
      MEUNITS_MAKE_UNIT_ID('Давление', 'дин/см^2',   'дины на сантиметр в квадрате',           ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 27);
      MEUNITS_MAKE_UNIT_ID('Давление', 'мм рт.ст.',  'миллиметры ртутного столба',             ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 28);
      MEUNITS_MAKE_UNIT_ID('Давление', 'мм вод.ст.', 'миллиметры водяного столба',             ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 29);
      MEUNITS_MAKE_UNIT_ID('Давление', 'м вод.ст.',  'метры водяного столба',                  ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 30);
      MEUNITS_MAKE_UNIT_ID('Давление', 'psi',        'фунты на квадратный дюйм',               ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 0, 31);
      MEUNITS_MAKE_UNIT_ID('Давление', 'гПа',        'гектопаскали',                           ID_ME_SYSTEM_OTHER,ID_ME_CAT_PRESSURE, 2, 32);

      // Энергия
      MEUNITS_MAKE_UNIT_ID('Энергия', 'Дж',  'джоули',     ID_ME_SYSTEM_SI,ID_ME_CAT_ENERGY, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Энергия', 'кДж', 'килоджоули', ID_ME_SYSTEM_SI,ID_ME_CAT_ENERGY, 3, 2);
      MEUNITS_MAKE_UNIT_ID('Энергия', 'МДж', 'мегаджоули', ID_ME_SYSTEM_SI,ID_ME_CAT_ENERGY, 6, 3);

      // Мощность
      MEUNITS_MAKE_UNIT_ID('Мощность', 'Вт',   'ватты',                        ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'кВт',  'киловатты',                    ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'МВт',  'мегаватты',                    ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'ГВт',  'гигаватты',                    ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'мВт',  'милливатты',                   ID_ME_SYSTEM_SI, ID_ME_CAT_POWER, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'мкВт', 'микроватты',                   ID_ME_SYSTEM_SI, ID_ME_CAT_POWER, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Мощность', 'л.с.', 'лошадиные силы (метрические)', ID_ME_SYSTEM_SI, ID_ME_CAT_POWER,  0, 13);

      // Температура
      MEUNITS_MAKE_UNIT_ID('Температура', '°K', 'градусы Кельвина',   ID_ME_SYSTEM_SI,    ID_ME_CAT_TEMPER, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Температура', '°C', 'градусы Цельсия',    ID_ME_SYSTEM_OTHER, ID_ME_CAT_TEMPER, 0, 1);
      MEUNITS_MAKE_UNIT_ID('Температура', '°F', 'градусы Фаренгейта', ID_ME_SYSTEM_OTHER, ID_ME_CAT_TEMPER, 0, 2);

      // Напряжение
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'В',   'вольты',      ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'кВ',  'киловольты',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'МВ',  'мегавольты',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'ГВ',  'гигавольты',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'мВ',  'милливольты', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'мкВ', 'микровольты', ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Напряжение', 'нВ',  'нановольты',  ID_ME_SYSTEM_SI, ID_ME_CAT_VOLTAGE, -9, 13);

      // Ток
      MEUNITS_MAKE_UNIT_ID('Ток', 'A',   'амперы',      ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Ток', 'кА',  'килоамперы',  ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Ток', 'мА',  'миллиамперы', ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Ток', 'мкА', 'микроамперы', ID_ME_SYSTEM_SI, ID_ME_CAT_CURRENT, -6, 12);

      // Сопротивление
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'Ом',    'омы',                      ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'кОм',   'килоомы',                  ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  3, 2);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'МОм',   'мегаомы',                  ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  6, 3);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'ГОм',   'гигаомы',                  ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST,  9, 4);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'мОм',   'миллиомы',                 ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -3, 11);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'мкОм',  'микроомы',                 ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -6, 12);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'нОм',   'наноомы',                  ID_ME_SYSTEM_SI,    ID_ME_CAT_RESIST, -9, 13);
      MEUNITS_MAKE_UNIT_ID('Сопротивление', 'мВ/мА', 'милливольт на миллиампер', ID_ME_SYSTEM_OTHER, ID_ME_CAT_RESIST,  0, 16);

      // Заряд
      MEUNITS_MAKE_UNIT_ID('Заряд', 'Кл',   'кулоны',          ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'абКл', 'абкулоны',        ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  1, 2);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'кКл',  'килокулоны',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  3, 3);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'МКл',  'мегаулоны',       ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE,  6, 4);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'мКл',  'милликулоны',     ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -3, 5);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'мкКл', 'микрокулоны',     ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -6, 6);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'нКл',  'нанокулоны',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -9, 7);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'пКл',  'пикокулоны',      ID_ME_SYSTEM_SI,    ID_ME_CAT_CHARGE, -12, 8);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'мА*ч', 'миллиампер-часы', ID_ME_SYSTEM_OTHER, ID_ME_CAT_CHARGE,  0, 15);
      MEUNITS_MAKE_UNIT_ID('Заряд', 'А*ч',  'ампер-часы',      ID_ME_SYSTEM_OTHER, ID_ME_CAT_CHARGE,  0, 16);

      // Отн. напряжение
      MEUNITS_MAKE_UNIT_ID('Относительное напряжение', 'В/В',  'вольт на вольт',      ID_ME_SYSTEM_SI, ID_ME_CAT_REL_VOLTAGE,  0, 1);
      MEUNITS_MAKE_UNIT_ID('Относительное напряжение', 'мВ/В', 'милливольт на вольт', ID_ME_SYSTEM_SI, ID_ME_CAT_REL_VOLTAGE, -3, 2);
    end;
  end;
end;

function MEUNITS_GET_ID_ByNameShort(const NameShort : String; out id : Int64) : HRESULT;
var
  i : Integer;
begin
  Fill_Measure_TypeArray;

  id := 0;
  Result := S_FALSE;

  for i := 0 to Length(Measure_TypeArray)-1 do
    begin
      if Measure_TypeArray[i].NameShort = NameShort then
        begin
          id := Measure_TypeArray[i].ID;
          Result := S_OK;
          Exit;
        end;
    end;
end;

function MEUNITS_GET_ID_ByNameFull(const NameFull : String; out id : Int64) : HRESULT;
var
  i : Integer;
begin
  Fill_Measure_TypeArray;

  id := 0;
  Result := S_FALSE;

  for i := 0 to Length(Measure_TypeArray)-1 do
    begin
      if Measure_TypeArray[i].NameFull = NameFull then
        begin
          id := Measure_TypeArray[i].ID;
          Result := S_OK;
          Exit;
        end;
    end;
end;

function MEUNITS_GET_NameShort_ByID(const id : Int64; out NameShort : String) : HRESULT;
var
  i : Integer;
begin
  Fill_Measure_TypeArray;

  NameShort := '-';
  Result := S_FALSE;

  for i := 0 to Length(Measure_TypeArray)-1 do
    begin
      if (Measure_TypeArray[i].ID = id) or (Measure_TypeArray[i].ID_NoCategory = id) then
        begin
          NameShort := Measure_TypeArray[i].NameShort;
          Result := S_OK;
          Exit;
        end;
    end;
end;

function MEUNITS_GET_NameFull_ByID(const id : Int64; out NameFull : String) : HRESULT;
var
  i : Integer;
begin
  Fill_Measure_TypeArray;

  NameFull := '-';
  Result := S_FALSE;

  for i := 0 to Length(Measure_TypeArray)-1 do
    begin
      if (Measure_TypeArray[i].ID = id) or (Measure_TypeArray[i].ID_NoCategory = id) then
        begin
          NameFull := Measure_TypeArray[i].NameFull;
          Result := S_OK;
          Exit;
        end;
    end;
end;


end.
