import useThingsMethod from '~/hooks/useThingsMethod'

const useThingsMint = (address: string) => {
  const { invoke, ...remaing } = useThingsMethod({ address, method: 'mint' })

  const mint = async (to: string, name: string) =>
    invoke({
      args: [to, name],
      metadata: {
        method: 'mint',
        message: `Mint thing with name ${name}`,
      },
    })

  return {
    ...remaing,
    mint,
  }
}

export default useThingsMint
