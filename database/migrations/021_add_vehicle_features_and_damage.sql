-- Add vehicle features and body damage fields
-- Generated on: 2026-01-26

-- Add features JSONB column for vehicle equipment/options
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}'::jsonb;

-- Add body_damage JSONB column for paint/damage information
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS body_damage JSONB DEFAULT '{}'::jsonb;

-- Create indexes for JSON queries
CREATE INDEX IF NOT EXISTS idx_vehicles_features ON vehicles USING GIN(features);
CREATE INDEX IF NOT EXISTS idx_vehicles_body_damage ON vehicles USING GIN(body_damage);

-- Add comments for documentation
COMMENT ON COLUMN vehicles.features IS 'Vehicle features/equipment stored as JSON. Categories: guvenlik (safety), ic_donanim (interior), dis_donanim (exterior), multimedya (multimedia)';
COMMENT ON COLUMN vehicles.body_damage IS 'Body damage/paint information stored as JSON. Each part has status: orijinal (original), lokal_boyali (locally painted), boyali (painted), degisen (replaced)';

/*
Example features structure:
{
  "guvenlik": ["ABS", "ESP", "Hava Yastigi (Surucu)", "Hava Yastigi (Yolcu)", "Merkezi Kilit", "Immobilizer"],
  "ic_donanim": ["Deri Koltuk", "Klima", "Elektrikli Camlar", "Geri Gorus Kamerasi", "Start/Stop"],
  "dis_donanim": ["Park Sensoru (On)", "Park Sensoru (Arka)", "Sunroof", "LED Farlar"],
  "multimedya": ["Bluetooth", "USB", "Apple CarPlay", "Android Auto"]
}

Example body_damage structure:
{
  "on_tampon": "orijinal",
  "on_kaput": "orijinal",
  "on_camurluk_sol": "lokal_boyali",
  "on_camurluk_sag": "boyali",
  "on_kapi_sol": "orijinal",
  "on_kapi_sag": "boyali",
  "arka_kapi_sol": "degisen",
  "arka_kapi_sag": "orijinal",
  "arka_camurluk_sol": "orijinal",
  "arka_camurluk_sag": "orijinal",
  "arka_tampon": "orijinal",
  "bagaj": "orijinal",
  "tavan": "orijinal"
}
*/
