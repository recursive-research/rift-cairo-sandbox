import { useState, useCallback } from 'react'
import { Json } from '~/types/json'

/**
 * Returns a function that returns the current value of storage at some key if
 * it exists, else it initializes storage with the given initial value.
 */
const getStorageInit =
  <T extends Json>(key: string, initial: T) =>
  () => {
    const storage = window.localStorage.getItem(key)
    if (!storage) {
      window.localStorage.setItem(key, JSON.stringify(initial))
      return initial
    }
    return JSON.parse(storage)
  }

const useLocalStorage = <V extends Json>(
  key: string,
  initial: V,
): [V, (value: V) => void] => {
  const [value, setValue] = useState<V>(getStorageInit(key, initial))

  const setValueAndStorage = useCallback(
    (value: V) => {
      window.localStorage.setItem(key, JSON.stringify(value))
      setValue(value)
    },
    [key],
  )

  return [value, setValueAndStorage]
}

export default useLocalStorage
