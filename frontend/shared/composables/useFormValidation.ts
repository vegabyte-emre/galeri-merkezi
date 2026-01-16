export const useFormValidation = () => {
  const validateEmail = (email: string): string | null => {
    if (!email) return 'E-posta adresi gereklidir'
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) return 'Geçerli bir e-posta adresi giriniz'
    return null
  }

  const validatePhone = (phone: string): string | null => {
    if (!phone) return 'Telefon numarası gereklidir'
    const phoneRegex = /^(\+90|0)?[5][0-9]{9}$/
    const cleaned = phone.replace(/\s/g, '')
    if (!phoneRegex.test(cleaned)) return 'Geçerli bir telefon numarası giriniz (örn: +90 5XX XXX XX XX)'
    return null
  }

  const validatePassword = (password: string): string | null => {
    if (!password) return 'Şifre gereklidir'
    if (password.length < 8) return 'Şifre en az 8 karakter olmalıdır'
    if (!/(?=.*[a-z])/.test(password)) return 'Şifre en az bir küçük harf içermelidir'
    if (!/(?=.*[A-Z])/.test(password)) return 'Şifre en az bir büyük harf içermelidir'
    if (!/(?=.*[0-9])/.test(password)) return 'Şifre en az bir rakam içermelidir'
    return null
  }

  const validateRequired = (value: string | number | null | undefined, fieldName: string): string | null => {
    if (value === null || value === undefined || value === '') {
      return `${fieldName} gereklidir`
    }
    return null
  }

  const validateMinLength = (value: string, minLength: number, fieldName: string): string | null => {
    if (value.length < minLength) {
      return `${fieldName} en az ${minLength} karakter olmalıdır`
    }
    return null
  }

  const validateMaxLength = (value: string, maxLength: number, fieldName: string): string | null => {
    if (value.length > maxLength) {
      return `${fieldName} en fazla ${maxLength} karakter olabilir`
    }
    return null
  }

  const validateNumber = (value: string | number, fieldName: string, min?: number, max?: number): string | null => {
    const num = typeof value === 'string' ? parseFloat(value) : value
    if (isNaN(num)) return `${fieldName} geçerli bir sayı olmalıdır`
    if (min !== undefined && num < min) return `${fieldName} en az ${min} olmalıdır`
    if (max !== undefined && num > max) return `${fieldName} en fazla ${max} olabilir`
    return null
  }

  const validateTCKN = (tckn: string): string | null => {
    if (!tckn) return 'TC Kimlik No gereklidir'
    if (tckn.length !== 11) return 'TC Kimlik No 11 haneli olmalıdır'
    if (!/^\d+$/.test(tckn)) return 'TC Kimlik No sadece rakamlardan oluşmalıdır'
    return null
  }

  const validateVKN = (vkn: string): string | null => {
    if (!vkn) return 'Vergi Kimlik No gereklidir'
    if (vkn.length !== 10) return 'Vergi Kimlik No 10 haneli olmalıdır'
    if (!/^\d+$/.test(vkn)) return 'Vergi Kimlik No sadece rakamlardan oluşmalıdır'
    return null
  }

  return {
    validateEmail,
    validatePhone,
    validatePassword,
    validateRequired,
    validateMinLength,
    validateMaxLength,
    validateNumber,
    validateTCKN,
    validateVKN
  }
}














