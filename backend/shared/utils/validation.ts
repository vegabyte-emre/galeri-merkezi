import { ValidationError } from './errors';

export function validateTCKN(tckn: string): boolean {
  if (!tckn || tckn.length !== 11) {
    return false;
  }

  // Check if all digits are the same
  if (/^(\d)\1{10}$/.test(tckn)) {
    return false;
  }

  // Validate checksum
  const digits = tckn.split('').map(Number);
  const sum1 = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
  const sum2 = digits[1] + digits[3] + digits[5] + digits[7];
  const check1 = (sum1 * 7 - sum2) % 10;
  const check2 = (sum1 + sum2 + digits[9]) % 10;

  return check1 === digits[9] && check2 === digits[10];
}

export function validateVKN(vkn: string): boolean {
  if (!vkn || vkn.length !== 10) {
    return false;
  }

  // Check if all digits are the same
  if (/^(\d)\1{9}$/.test(vkn)) {
    return false;
  }

  // Validate checksum
  const digits = vkn.split('').map(Number);
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    const temp = (digits[i] + (10 - i)) % 10;
    sum += temp === 9 ? 9 : (temp * Math.pow(2, 10 - i)) % 9;
  }
  const check = (10 - (sum % 10)) % 10;

  return check === digits[9];
}

export function validatePhone(phone: string): boolean {
  // Turkish phone format: +90XXXXXXXXXX
  const phoneRegex = /^\+90[0-9]{10}$/;
  return phoneRegex.test(phone);
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validatePassword(password: string): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long');
  }
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }
  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

export function sanitizeInput(input: string): string {
  return input.trim().replace(/[<>]/g, '');
}
















