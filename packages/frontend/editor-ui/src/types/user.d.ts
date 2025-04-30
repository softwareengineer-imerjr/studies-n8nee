import { IUser as IBaseUser } from '@/Interface';

// Estendendo a interface IUser para incluir o tenantId
declare module '@/Interface' {
	export interface IUser extends IBaseUser {
		tenantId?: string;
	}
}
