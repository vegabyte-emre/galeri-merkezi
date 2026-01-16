/**
 * TurkiyeAPI - Türkiye'nin idari yapısı için ücretsiz REST API
 * https://docs.turkiyeapi.dev
 */

export interface City {
  id: number
  name: string
  plateCode: string
}

export interface District {
  id: number
  name: string
  cityId: number
}

export interface Neighborhood {
  id: number
  name: string
  districtId: number
}

export const useTurkiyeAPI = () => {
  const baseUrl = 'https://api.turkiyeapi.dev/api/v1'

  /**
   * Tüm illeri getir
   */
  const getCities = async (): Promise<City[]> => {
    try {
      const response = await fetch(`${baseUrl}/provinces`)
      if (!response.ok) {
        throw new Error('İller yüklenemedi')
      }
      const data = await response.json()
      console.log('Cities API response:', data)
      
      // API response formatına göre düzenle
      const cities = data.data || data.items || data || []
      
      return cities.map((city: any) => ({
        id: city.id || city.plateCode,
        name: city.name,
        plateCode: city.plateCode || city.id
      }))
    } catch (error) {
      console.error('Error fetching cities:', error)
      return []
    }
  }

  /**
   * Belirli bir ile ait ilçeleri getir
   * cityId: İl ID'si veya plaka kodu
   */
  const getDistricts = async (cityId: number): Promise<District[]> => {
    try {
      console.log('Fetching districts for city ID:', cityId)
      
      // Önce /provinces/{id}/districts endpoint'ini dene
      let response = await fetch(`${baseUrl}/provinces/${cityId}/districts`)
      let data: any = null
      
      if (response.ok) {
        data = await response.json()
        console.log('Districts API response (provinces endpoint):', data)
      } else {
        // Alternatif: /districts?province={id} endpoint'ini dene
        console.log('Trying alternative endpoint...')
        response = await fetch(`${baseUrl}/districts?province=${cityId}`)
        
        if (response.ok) {
          data = await response.json()
          console.log('Districts API response (districts endpoint):', data)
        } else {
          // Son alternatif: /provinces/{id} endpoint'inden districts'i al
          console.log('Trying province detail endpoint...')
          response = await fetch(`${baseUrl}/provinces/${cityId}`)
          
          if (response.ok) {
            const provinceData = await response.json()
            console.log('Province detail response:', provinceData)
            
            // Province detail'den districts'i çıkar
            if (provinceData.data?.districts) {
              data = { data: provinceData.data.districts }
            } else if (provinceData.districts) {
              data = { data: provinceData.districts }
            }
          }
        }
      }
      
      if (!data) {
        throw new Error(`İlçeler yüklenemedi: ${response.status}`)
      }
      
      // API response formatına göre veriyi işle
      const districts = data.data || data.items || data.districts || data || []
      
      if (!Array.isArray(districts)) {
        console.error('Districts is not an array:', districts)
        return []
      }
      
      const mappedDistricts = districts.map((district: any) => ({
        id: district.id || district.districtId,
        name: district.name,
        cityId: cityId
      }))
      
      console.log('Mapped districts:', mappedDistricts)
      return mappedDistricts
    } catch (error: any) {
      console.error('Error fetching districts:', error)
      console.error('Error details:', error.message, error.stack)
      return []
    }
  }

  /**
   * Belirli bir ilçeye ait mahalleleri getir
   */
  const getNeighborhoods = async (districtId: number): Promise<Neighborhood[]> => {
    try {
      const response = await fetch(`${baseUrl}/districts/${districtId}/neighborhoods`)
      if (!response.ok) {
        throw new Error('Mahalleler yüklenemedi')
      }
      const data = await response.json()
      return data.data?.map((neighborhood: any) => ({
        id: neighborhood.id,
        name: neighborhood.name,
        districtId: districtId
      })) || []
    } catch (error) {
      console.error('Error fetching neighborhoods:', error)
      return []
    }
  }

  return {
    getCities,
    getDistricts,
    getNeighborhoods
  }
}

