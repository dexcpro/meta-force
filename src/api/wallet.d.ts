declare module '@/api/wallet' {
	export function getprovider(): Promise<any>
	export function checkNetwork(): Promise<any>
}