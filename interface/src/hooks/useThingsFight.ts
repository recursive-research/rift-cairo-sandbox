import useThingsMethod from '~/hooks/useThingsMethod'

const useThingsFight = (address: string) => {
  const { invoke, ...remaining } = useThingsMethod({ address, method: 'fight' })

  const fight = async (opponent: string) =>
    invoke({
      args: [opponent],
      metadata: {
        method: 'fight',
        message: `Fight! Opponent: ${opponent}`,
      },
    })

  return {
    ...remaining,
    fight,
  }
}

export default useThingsFight
