/// Oeffentlicher Ed25519-Schluessel zur Pruefung von Zeitexa-Firmenlizenzen.
///
/// Das Gegenstueck (der PRIVATE Schluessel) liegt ausschliesslich lokal beim
/// Entwickler im Ordner tools/lizenz_generator/schluessel/ und wird niemals
/// committet. Dieser oeffentliche Schluessel darf dagegen bedenkenlos in der
/// App enthalten sein - er kann nur PRUEFEN, nicht ERZEUGEN.
///
/// Erzeugt am 2026-07-15 mit:
///   dart run tools/lizenz_generator/bin/lizenz_generator.dart keygen
const List<int> oeffentlicherSchluesselBytes = [
  132, 226, 148, 9, 60, 180, 144, 109, 62, 180, 228, 133, 217, 172, 134, 241,
  136, 198, 42, 79, 31, 168, 67, 59, 129, 206, 175, 109, 52, 169, 211, 157,
];
