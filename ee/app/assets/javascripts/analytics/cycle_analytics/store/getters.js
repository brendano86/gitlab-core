import dateFormat from 'dateformat';
import httpStatus from '~/lib/utils/http_status';
import { dateFormats } from '../../shared/constants';
import { getDurationChartData } from '../utils';

export const defaultStage = state => (state.stages.length ? state.stages[0] : null);

export const hasNoAccessError = state => state.errorCode === httpStatus.FORBIDDEN;

export const currentGroupPath = ({ selectedGroup }) =>
  selectedGroup && selectedGroup.fullPath ? selectedGroup.fullPath : null;

export const cycleAnalyticsRequestParams = ({
  startDate = null,
  endDate = null,
  selectedProjectIds = [],
}) => ({
  project_ids: selectedProjectIds,
  created_after: startDate ? dateFormat(startDate, dateFormats.isoDate) : null,
  created_before: endDate ? dateFormat(endDate, dateFormats.isoDate) : null,
});

export const durationChartPlottableData = state => {
  const { durationData, startDate, endDate } = state;
  const selectedStagesDurationData = durationData.filter(stage => stage.selected);
  const plottableData = getDurationChartData(selectedStagesDurationData, startDate, endDate);

  return plottableData.length ? plottableData : null;
};
