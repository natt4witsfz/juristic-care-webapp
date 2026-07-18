import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';

import { HousekeepingRoutinePage } from './housekeeping_routine_page';
import { MockHousekeepingRoutineRepository } from './mock_housekeeping_repository';

class MemoryStorage implements Storage {
  private readonly values = new Map<string, string>();
  get length() {
    return this.values.size;
  }
  clear() {
    this.values.clear();
  }
  getItem(key: string) {
    return this.values.get(key) ?? null;
  }
  key(index: number) {
    return [...this.values.keys()][index] ?? null;
  }
  removeItem(key: string) {
    this.values.delete(key);
  }
  setItem(key: string, value: string) {
    this.values.set(key, value);
  }
}

function renderPage() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  const repository = new MockHousekeepingRoutineRepository(new MemoryStorage());
  render(
    <QueryClientProvider client={queryClient}>
      <HousekeepingRoutinePage repository={repository} />
    </QueryClientProvider>,
  );
}

describe('HousekeepingRoutinePage', () => {
  it('updates the Board immediately after approval and Reset Demo Data restores it', async () => {
    renderPage();
    fireEvent.click(
      await screen.findByRole('button', {
        name: /HK-02 ทำความสะอาด Lobby รอตรวจ เปิดหลักฐาน/,
      }),
    );
    expect(await screen.findByRole('dialog', { name: 'Inspection Drawer' })).toBeVisible();

    fireEvent.click(await screen.findByRole('button', { name: 'อนุมัติ' }));
    fireEvent.click(screen.getByRole('button', { name: 'ยืนยันอนุมัติ' }));

    expect(
      await screen.findByRole('button', {
        name: /HK-02 ทำความสะอาด Lobby ผ่านแล้ว เปิดหลักฐาน/,
      }),
    ).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: 'ปิดแผงตรวจ' }));

    fireEvent.click(screen.getByRole('button', { name: 'Reset Demo Data' }));
    fireEvent.click(screen.getByRole('button', { name: 'ยืนยัน Reset' }));

    expect(await screen.findByText('คืนข้อมูลจำลองเป็นค่าเริ่มต้นแล้ว')).toBeVisible();
    expect(
      await screen.findByRole('button', {
        name: /HK-02 ทำความสะอาด Lobby รอตรวจ เปิดหลักฐาน/,
      }),
    ).toBeVisible();
  });

  it('requires a rejection reason and shows the rejected state on the Board', async () => {
    renderPage();
    fireEvent.click(
      await screen.findByRole('button', {
        name: /HK-02 ทำความสะอาด Lobby รอตรวจ เปิดหลักฐาน/,
      }),
    );
    fireEvent.click(await screen.findByRole('button', { name: 'ไม่อนุมัติ' }));

    const confirmButton = screen.getByRole('button', { name: 'ยืนยันไม่อนุมัติ' });
    expect(confirmButton).toBeDisabled();
    fireEvent.click(screen.getByLabelText('พื้นที่ยังไม่สะอาด'));
    expect(confirmButton).toBeEnabled();
    fireEvent.click(confirmButton);

    await waitFor(() =>
      expect(
        screen.getByRole('button', {
          name: /HK-02 ทำความสะอาด Lobby ไม่ผ่าน เปิดหลักฐาน/,
        }),
      ).toBeVisible(),
    );
  });
});
