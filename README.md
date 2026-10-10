# ryddeScript

Et eldre VBScript for opprydding på Windows-maskiner og Windows-servere.

## Viktig advarsel

Scriptet er fra 2015 og utfører omfattende, potensielt destruktive handlinger, blant annet sletting av filer, skyggekopier og gjenopprettingspunkter. Det inneholder også logikk for eldre Windows-, Exchange-, IIS- og WSUS-miljøer.

Ikke kjør scriptet på en produksjonsmaskin uten å:

1. lese og forstå hele kildekoden;
2. tilpasse den til dagens Windows-versjon og miljø;
3. ha verifiserte sikkerhetskopier;
4. teste i en isolert virtuell maskin først.

## Innhold

- `ryddeScript.vbs` – oppryddingsscriptet, publisert i eksisterende form.

## Kjøring

Krever normalt administrative rettigheter. Etter full kodegjennomgang kan scriptet startes fra en administrativ kommandolinje:

```bat
cscript //nologo ryddeScript.vbs
```

Bruk skjer på eget ansvar.
