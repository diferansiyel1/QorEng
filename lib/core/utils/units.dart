/// Electrical units for engineering calculations.
///
/// These enums provide type-safe unit selection and conversion
/// for electrical engineering calculations.
library;

// Voltage units
enum VoltageUnit {
  microV('µV', 1e-6),
  milliV('mV', 1e-3),
  volt('V', 1.0),
  kiloV('kV', 1e3),
  megaV('MV', 1e6);

  const VoltageUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}

// Current units
enum CurrentUnit {
  microA('µA', 1e-6),
  milliA('mA', 1e-3),
  amp('A', 1.0),
  kiloA('kA', 1e3);

  const CurrentUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}

// Resistance units
enum ResistanceUnit {
  milliOhm('mΩ', 1e-3),
  ohm('Ω', 1.0),
  kiloOhm('kΩ', 1e3),
  megaOhm('MΩ', 1e6);

  const ResistanceUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}

// Power units
enum PowerUnit {
  microW('µW', 1e-6),
  milliW('mW', 1e-3),
  watt('W', 1.0),
  kiloW('kW', 1e3),
  megaW('MW', 1e6),
  gigaW('GW', 1e9);

  const PowerUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}

// Energy units
enum EnergyUnit {
  wattHour('Wh', 1.0),
  kiloWattHour('kWh', 1e3),
  megaWattHour('MWh', 1e6),
  joule('J', 1 / 3600),
  kiloJoule('kJ', 1000 / 3600);

  const EnergyUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}

// Frequency units
enum FrequencyUnit {
  milliHz('mHz', 1e-3),
  hertz('Hz', 1.0),
  kiloHz('kHz', 1e3),
  megaHz('MHz', 1e6),
  gigaHz('GHz', 1e9);

  const FrequencyUnit(this.symbol, this.toBaseMultiplier);

  final String symbol;
  final double toBaseMultiplier;

  @override
  String toString() => symbol;
}
