import { describe, it, expect } from 'vitest'
import { value_converter } from '../data.js'

describe('value_converter', () => {
  it('should convert billions correctly', () => {
    expect(value_converter(1000000000)).toBe('1B')
    expect(value_converter(1500000000)).toBe('1.5B')
    expect(value_converter(2000000000)).toBe('2B')
    expect(value_converter(2100000000)).toBe('2.1B')
  })

  it('should convert millions correctly', () => {
    expect(value_converter(1000000)).toBe('1M')
    expect(value_converter(1500000)).toBe('1.5M')
    expect(value_converter(2000000)).toBe('2M')
    expect(value_converter(2100000)).toBe('2.1M')
    expect(value_converter(999999999)).toBe('1000M')
  })

  it('should convert thousands correctly', () => {
    expect(value_converter(1000)).toBe('1K')
    expect(value_converter(1500)).toBe('1.5K')
    expect(value_converter(2000)).toBe('2K')
    expect(value_converter(2100)).toBe('2.1K')
    expect(value_converter(999999)).toBe('1000K')
  })

  it('should return original value for numbers less than 1000', () => {
    expect(value_converter(999)).toBe('999')
    expect(value_converter(500)).toBe('500')
    expect(value_converter(1)).toBe('1')
    expect(value_converter(0)).toBe('0')
  })

  it('should handle edge cases', () => {
    expect(value_converter(1000000000000)).toBe('1000B')
    expect(value_converter(1001000000)).toBe('1B')
    expect(value_converter(1001000)).toBe('1M')
    expect(value_converter(1001)).toBe('1K')
  })

  it('should remove trailing zeros from decimals', () => {
    expect(value_converter(1000000000)).toBe('1B') // Should be '1B', not '1.0B'
    expect(value_converter(2000000000)).toBe('2B') // Should be '2B', not '2.0B'
    expect(value_converter(1000000)).toBe('1M') // Should be '1M', not '1.0M'
    expect(value_converter(1000)).toBe('1K') // Should be '1K', not '1.0K'
  })
})
