# DETS to PostgreSQL constitutional registry migration

Use this one-time path only when an existing DETS registry must be preserved.
The PostgreSQL target must be empty, and the source application must no longer
accept registry writes while its file is copied.

1. Stop or place the DETS-backed release into maintenance.
2. Copy and checksum the configured `parkinging_stands.dets` file.
3. Deploy the PostgreSQL-backed release and run its Ecto migration.
4. Make the copied DETS file available to a one-off process.
5. Run:

       bin/public_situation_machine_turn_zero eval \
         'IO.inspect(PublicSituationMachineTurnZero.DetsRegistryImporter.import("/absolute/path/parkinging_stands.dets"))'

The importer preserves existing Parkinging Stand numbers, plaintext Shackling
PINs, original Leashing ceremony times, Situationing Name history,
Appointmentings presently represented in DETS, and XT–YT Interrelationing
history. It then advances the PostgreSQL Parkinging Stand sequence beyond both
the imported maximum and DETS `:last_number`.

The import intentionally fails on uniqueness or malformed-data errors rather
than silently replacing PostgreSQL rows. Keep the original DETS file and its
checksum until lawful return and reconstructed Standing have been verified.

If the prior Gigalixir replica and its local DETS file are no longer accessible,
there is no source data for an importer to recover. In that case PostgreSQL must
begin with a clean registry at Parkinging Stand `000000000002`.
