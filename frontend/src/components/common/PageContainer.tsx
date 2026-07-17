import type { ElementType, PropsWithChildren } from 'react';

interface PageContainerProps extends PropsWithChildren {
  readonly as?: ElementType;
}

export function PageContainer({ as: Component = 'div', children }: PageContainerProps) {
  return <Component className="mx-auto w-full max-w-6xl px-6 py-12">{children}</Component>;
}
